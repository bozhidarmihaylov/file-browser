//
//  FolderContentPaginator.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FolderContentPaginator: AnyObject {
    func loadMore()
    
    var input: FolderContentPaginatorInput! { get set }
    var output: FolderContentPaginatorOutput! { get set }
}

protocol FolderContentPaginatorInput: AnyObject {
    func loadNextPage() async throws -> [Entry]?
}

protocol FolderContentPaginatorOutput: AnyObject {
    func didStartLoadingNewPage()
    
    func didFinishLoadingNewPage(with result: Result<[Entry], Error>)
}

final class FolderContentPaginatorImpl: FolderContentPaginator {
    init(
        taskLauncher: TaskLauncher = TaskLauncherImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl()
    ) {
        self.taskLauncher = taskLauncher
        self.mainActorRunner = mainActorRunner
    }
    
    private let taskLauncher: TaskLauncher
    private let mainActorRunner: MainActorRunner
    
    weak var input: FolderContentPaginatorInput!
    weak var output: FolderContentPaginatorOutput!
    
    private var loadNextPageTask: Task<Void, Error>? = nil
    private var hasLoadedAllPages = false
        
    func loadMore() {
        if (hasLoadedAllPages || loadNextPageTask != nil) { return }
        
        output?.didStartLoadingNewPage()
        
        loadNextPageTask = taskLauncher.launch { [weak self] in
            guard let self else {
                return
            }
            
            var page: [Entry]? = nil
            var err: Error? = nil
            
            do {
                page = try await input.loadNextPage()
            } catch {
                err = error
            }
            
            await mainActorRunner.run { [weak self, page, err] in
                guard let self else { return }
                
                defer {
                    output?.didFinishLoadingNewPage(
                        with: err.map { .failure($0) }
                            ?? .success(page ?? [])
                    )
                }
                
                loadNextPageTask = nil
                
                if err == nil 
                    && page?.count ?? 0 == 0
                {
                    hasLoadedAllPages = true
                }
            }
        }
    }
}
