//
//  FileBrowserController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileBrowserController
    : FileBrowserViewOutput
    , FolderContentPaginatorInput
    , FolderContentPaginatorOutput
{
    
}

final class FileBrowserControllerImpl  {
    init(
        path: String = "",
        folderContent: FolderContent,
        navigator: FileBrowserNavigator,
        repositoryFactory: BucketRepositoryFactory = ApiBucketRepositoryFactoryImpl(),
        contentPaginator: FolderContentPaginator = FolderContentPaginatorImpl(),
        notificationSubject: NotificationSubject = NotificationSubjectImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl(),
        taskLauncher: TaskLauncher = TaskLauncherImpl(),
        errorAlertPresenter: ErrorAlertPresenter = ErrorAlertPresenterImpl(),
        downloadEventBus: FileDownloadEventBus = FileDownloadEventBusImpl()
    ) {
        self.path = path
        self.folderContent = folderContent
        self.navigator = navigator
        self.repositoryFactory = repositoryFactory
        self.notificationSubject = notificationSubject
        self.mainActorRunner = mainActorRunner
        self.taskLauncher = taskLauncher
        self.contentPaginator = contentPaginator
        self.errorAlertPresenter = errorAlertPresenter
        self.downloadEventBus = downloadEventBus
        
        self.contentPaginator.input = self
        self.contentPaginator.output = self
    }
    
    weak var view: FileBrowserView? = nil
    
    private let path: String
    private let folderContent: FolderContent
    private let navigator: FileBrowserNavigator
    
    private let repositoryFactory: BucketRepositoryFactory
    private let contentPaginator: FolderContentPaginator
    private let notificationSubject: NotificationSubject
    private let mainActorRunner: MainActorRunner
    private let taskLauncher: TaskLauncher
    private let errorAlertPresenter: ErrorAlertPresenter
    private let downloadEventBus: FileDownloadEventBus
    
    private lazy var repository: BucketRepository = try! repositoryFactory.createBucketRepository()!
    private(set) var pageIterator: AnyAsyncSequence<[Entry]>.AsyncIterator? = nil

    private var loadNextPageTask: Task<Void, Error>? = nil
    private var hasLoadedAllPages = false
        
    private var willEnterForegroundSubscription: Cancellable? = nil
    private var didDownloadFileSubscription: Cancellable? = nil
    private func subscribe() {
        willEnterForegroundSubscription?.cancel()        
        willEnterForegroundSubscription = notificationSubject.subscribe(
            name: "UIApplicationWillEnterForegroundNotification"
        ) { [weak self] _ in
            self?.syncEntriesLocally()
        }
        
        didDownloadFileSubscription?.cancel()
        didDownloadFileSubscription = downloadEventBus.subscribe(
            parentPath: path
        ) { [weak self] filePath, error in
            self?.syncEntriesLocally()
        }
    }
    
    private func unsubscribe() {
        willEnterForegroundSubscription?.cancel()
        willEnterForegroundSubscription = nil
        
        didDownloadFileSubscription?.cancel()
        didDownloadFileSubscription = nil
    }
    
    private func syncEntriesLocally() {
        taskLauncher.launch { [weak self] in
            guard let self else { return }
            
            try await folderContent.syncLoadingStates()
            
            await mainActorRunner.run { [weak self] in
                guard let self, let view else { return }
                
                view.updateAccessoryViewForRows(at: view.visibleIndexPaths)
            }
        }
    }
}

extension FileBrowserControllerImpl: FileBrowserViewOutput {
    func onInit() {
        subscribe()
    }
    
    func onDeinit() {
        unsubscribe()
    }
    
    func onViewLoaded() {
        let result = repository.getContent(path: path)
        pageIterator = result.makeAsyncIterator()
        
        contentPaginator.loadMore()
    }
    
    func onViewAppeared() {
        syncEntriesLocally()
    }
    
    func onRightButtonItemTap() {
        navigator.onRightButtonItemTap()
    }
    
    func onCellTap(at indexPath: IndexPath) {
        let entry = folderContent.entry(at: indexPath.row)

        if entry.isFolder {
            navigator.goToFolder(entry)
        } else if entry.loadingState == .loaded {
            navigator.goToFile(entry)
        }
        
        view?.deselectCell(at: indexPath)
    }
    
    func onCellAccessoryTap(at indexPath: IndexPath) {
        let index = indexPath.row
        
        let entry = folderContent.entry(at: index)
        let path = entry.path
        let initialLoadingState = entry.loadingState
        
        folderContent.setLoadingState(.loading, at: path)
        view?.updateAccessoryViewForRows(at: [indexPath])
        
        taskLauncher.launch { [weak self] in
            guard let self else { return }
            
            let loadingState: LoadingState
            let err: Error?
            
            do {
                loadingState = try await repository.downloadFile(
                    path: path
                ).loadingState
                err = nil
            } catch {
                loadingState = initialLoadingState
                err = error
            }
            
            await mainActorRunner.run { [weak self] in
                guard let self else { return }

                if let err {
                    errorAlertPresenter.showErrorAlert(
                        of: err,
                        with: "File download failed",
                        on: view?.node
                    )
                }
                
                folderContent.setLoadingState(loadingState, at: path)
                view?.updateAccessoryViewForRows(at: [indexPath])
            }
        }
    }
    
    func shouldHighlightRow(at indexPath: IndexPath) -> Bool {
        let entry = folderContent.entry(at: indexPath.row)
        
        return entry.isFolder || entry.loadingState == .loaded
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if (indexPath.row == folderContent.numberOfEntries() - 1) {
            contentPaginator.loadMore()
        }
    }
}

extension FileBrowserControllerImpl: FolderContentPaginatorInput {
    func loadNextPage() async throws -> [Entry]? {
        try await pageIterator?.next()
    }
}

extension FileBrowserControllerImpl: FolderContentPaginatorOutput {
    func didStartLoadingNewPage() {}
    
    func didFinishLoadingNewPage(
        with result: Result<[Entry], Error>
    ) {
        switch result {
        case .success(let newPage):
            let firstIndex = folderContent.numberOfEntries()
            folderContent.append(entries: newPage)
            
            guard firstIndex > 0 else {
                view?.reloadData()
                return
            }

            view?.insertRows(
                at: IndexPath(row: firstIndex, section: 0),
                count: newPage.count
            )
            
        case .failure(let error):
            errorAlertPresenter.showErrorAlert(
                of: error,
                with: "Loading folder content failed",
                on: view?.node
            )
        }
    }
}
