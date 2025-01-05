//
//  FolderContent.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FolderContent: AnyObject {
    func numberOfEntries() -> Int
    func entry(at index: Int) -> Entry
    
    func append(entries: [Entry])
    func syncLoadingStates() async throws
    func setLoadingState(
        _ loadingState: LoadingState,
        at path: String
    )
    
    var output: FolderContentOutput? { get set }
}

protocol FolderContentOutput: AnyObject {
    func didAppendEntries(_ entries: [Entry])
    func didSyncLoadingStates()
    func didUpdateLoadingState(at index: Int)
}

enum FolderContentError: Error {
    case indexOutOfBounds
}

final class FolderContentImpl {
    init(
        path: String,
        loadingStateSyncer: LoadingStateSyncer = LoadingStateSyncerImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl()
    ) {
        self.path = path
        self.loadingStateSyncer = loadingStateSyncer
        self.mainActorRunner = mainActorRunner
    }
    
    private let path: String
    private let loadingStateSyncer: LoadingStateSyncer
    private let mainActorRunner: MainActorRunner
    
    private(set) var entries: [Entry] = []
    
    weak var output: FolderContentOutput?
}

extension FolderContentImpl: FolderContent {
    func numberOfEntries() -> Int {
        entries.count
    }
    
    func entry(at index: Int) -> Entry {
        entries[index]
    }
    
    func append(entries: [Entry]) {
        self.entries.append(contentsOf: entries)
        
        output?.didAppendEntries(entries)
    }
    
    func syncLoadingStates() async throws {
        let entiresCopy = await mainActorRunner.run { entries }

        let newEntries = try await loadingStateSyncer.syncedLoadingStates(
          for: entiresCopy
        )
        
        await mainActorRunner.run { [weak self] in
            guard let self else { return }
            
            entries = newEntries
            
            output?.didSyncLoadingStates()
        }
    }
    
    func setLoadingState(
        _ loadingState: LoadingState,
        at path: String
    ) {
        let index = entries.firstIndex { $0.path == path }
        
        guard let index else { return }
        
        entries[index].loadingState = loadingState
        
        output?.didUpdateLoadingState(at: index)
    }
}
