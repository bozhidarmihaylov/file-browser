//
//  FileBrowserController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol FileBrowserController {
    func cellCount() -> Int
    func cellVm(at indexPath: IndexPath) -> EntryCellVm
    func cellAccessoryVm(at indexpath: IndexPath) -> AccessoryVm
    
    func onInit()
    func onDeinit()
    func onViewLoaded()
    func onViewAppeared()
    
    func onRightButtonItemTap()
    
    func onCellTap(at indexPath: IndexPath)
    func onCellAccessoryTap(at indexPath: IndexPath)
    
    func shouldHighlightRow(at indexPath: IndexPath) -> Bool
    
    func willDisplayCell(at indexPath: IndexPath)
}

final class FileBrowserControllerImpl  {
    init(
        path: String = "",
        navigator: FileBrowserNavigator,
        cellVmFactory: FileBrowserCellVmFactory = FileBrowserVmFactoryImpl(),
        repositoryFactory: BucketRepositoryFactory = ApiBucketRepositoryFactoryImpl(),
        notificationSubject: NotificationSubject = NotificationSubjectImpl(),
        loadingStateSyncer: LoadingStateSyncer = LoadingStateSyncerImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl()
    ) {
        self.path = path
        self.navigator = navigator
        self.cellVmFactory = cellVmFactory
        self.repositoryFactory = repositoryFactory
        self.notificationSubject = notificationSubject
        self.loadingStateSyncer = loadingStateSyncer
        self.mainActorRunner = mainActorRunner
    }
    
    weak var view: FileBrowserView? = nil
    
    private let path: String
    private let navigator: FileBrowserNavigator
    
    private let cellVmFactory: FileBrowserCellVmFactory
    private let repositoryFactory: BucketRepositoryFactory
    private let notificationSubject: NotificationSubject
    private let loadingStateSyncer: LoadingStateSyncer
    private let mainActorRunner: MainActorRunner
    
    private lazy var repository: BucketRepository = try! repositoryFactory.createBucketRepository()!
    private var pageIterator: AnyAsyncSequence<[Entry]>.AsyncIterator? = nil

    private var entries: [Entry] = []
    
    private var loadNextPageTask: Task<Void, Never>? = nil
    private var hasLoadedAllPages = false
        
    private var cellVms: [EntryCellVm] = []
    
    private func entry(at indexPath: IndexPath) -> Entry {
        entries[indexPath.row]
    }
    
    private var willEnterForegroundSubscription: Cancellable? = nil
    private func subscribe() {
        willEnterForegroundSubscription?.cancel()
        
        willEnterForegroundSubscription = notificationSubject.subscribe(
            name: "UIApplicationWillEnterForegroundNotification"
        ) { [weak self] _ in
            self?.syncEntriesLocally()
        }
    }
    
    private func unsubscribe() {
        willEnterForegroundSubscription?.cancel()
        willEnterForegroundSubscription = nil
    }
    
    private func syncEntriesLocally() {
        let entiresCopy = entries
        Task { [weak self] in
            guard let self else { return }
            
            let newEntries = try await loadingStateSyncer.syncedLoadingStates(
              for: entiresCopy
            )
            
            await mainActorRunner.run { [weak self] in
                guard let self else { return }
                
                entries = newEntries
                
                cellVms = cellVmFactory.createVm(entries: entries)
                
                for indexPath in view?.visibleIndexPaths ?? [] {
                    guard indexPath.row < cellVms.count else { return }
                    
                    view?.configureCellAccessoryView(
                        at: indexPath,
                        with: cellVms[indexPath.row].accessoryVm
                    )
                }
            }
        }
    }
}

extension FileBrowserControllerImpl: FileBrowserController {
    func cellCount() -> Int {
        cellVms.count
    }
    
    func cellVm(at indexPath: IndexPath) -> EntryCellVm {
        cellVms[indexPath.row]
    }
    
    func cellAccessoryVm(at indexPath: IndexPath) -> AccessoryVm {
        cellVms[indexPath.row].accessoryVm
    }
    
    func onInit() {
        subscribe()
    }
    
    func onDeinit() {
        unsubscribe()
    }
    
    func onViewLoaded() {
        let result = repository.getContent(path: path)
        pageIterator = result.makeAsyncIterator()
        
        entries = []
        
        loadMore()
    }
    
    func onViewAppeared() {
        syncEntriesLocally()
    }
    
    func onRightButtonItemTap() {
        navigator.onRightButtonItemTap()
    }
    
    func onCellTap(at indexPath: IndexPath) {
        let entry = entries[indexPath.row]

        if entry.isFolder {
            navigator.goToFolder(entry)
        } else if entry.loadingState == .loaded {
            navigator.goToFile(entry)
        }
        
        view?.deselectCell(at: indexPath)
    }
    
    func onCellAccessoryTap(at indexPath: IndexPath) {
        let index = indexPath.row
        
        guard entries.indices.contains(index) else { return }
        
        var entry = entries[index]
        entry.loadingState = .loading
        entries[index] = entry
        
        let cellVm = cellVmFactory.createVm(entry: entry)
        cellVms[index] = cellVm
        
        view?.configureCellAccessoryView(
            at: indexPath,
            with: cellVm.accessoryVm
        )
        
        Task { [weak self, entry] in
            guard let self else { return }
            
            let updatedEntry: Entry
            
            if let fetchedEntry = try? await repository.downloadFile(
                   path: entry.path
               )
            {
                updatedEntry = fetchedEntry
            } else {
                updatedEntry = {
                    var it = entry
                    it.loadingState = .notLoaded
                    return it
                }()
            }
            
            await mainActorRunner.run { [weak self] in
                guard let self else { return }

                entries[index] = updatedEntry
                
                let cellVm = cellVmFactory.createVm(entry: updatedEntry)
                cellVms[index] = cellVm
                
                view?.configureCellAccessoryView(
                    at: indexPath,
                    with: cellVm.accessoryVm
                )
            }
        }
    }
    
    func shouldHighlightRow(at indexPath: IndexPath) -> Bool {
        let entry = entry(at: indexPath)
        
        return entry.isFolder || entry.loadingState == .loaded
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if (indexPath.row == cellVms.count - 1) {
            loadMore()
        }
    }
}

extension FileBrowserControllerImpl {
    private func loadMore() {
        if (hasLoadedAllPages || loadNextPageTask != nil) { return }
        
        loadNextPageTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            var page: [Entry]? = nil
            
            do { page = try await pageIterator?.next() }
            catch { print(error) }
            
            await mainActorRunner.run { [weak self, page] in
                guard let self else { return }
                
                loadNextPageTask = nil
                
                guard let page,
                      page.count > 0
                else {
                    hasLoadedAllPages = true
                    return
                }
                
                let firstIndex = entries.count
                entries.append(contentsOf: page)
                cellVms.append(contentsOf: cellVmFactory.createVm(entries: page))
                
                guard firstIndex > 0 else {
                    view?.reloadData()
                    return
                }

                view?.insertRows(
                    at: IndexPath(row: firstIndex, section: 0),
                    count: page.count
                )
            }
        }
    }
}
