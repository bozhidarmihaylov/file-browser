//
//  ApiEntryPageSequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class ApiEntryPageSequence: AsyncSequence {
    typealias AsyncIterator = PageIterator
    typealias Element = [Entry]
    
    init(
        path: String,
        pageSize: Int,
        apiConfigProvider: ApiConfigProvider = ApiConfigStoreImpl.shared,
        folderContentLoader: FolderContentLoader = FolderContentLoaderImpl()
    ) {
        self.path = path
        self.pageSize = pageSize
        self.apiConfigProvider = apiConfigProvider
        self.folderContentLoader = folderContentLoader
    }

    private let path: String
    private let pageSize: Int
    private let apiConfigProvider: ApiConfigProvider
    private let folderContentLoader: FolderContentLoader
    
    func makeAsyncIterator() -> PageIterator {
        PageIterator(
            path: path,
            pageSize: pageSize,
            apiConfigProvider: apiConfigProvider,
            folderContentLoader: folderContentLoader
        )
    }
    
    final class PageIterator: AsyncIteratorProtocol {
        init(
            path: String,
            pageSize: Int,
            apiConfigProvider: ApiConfigProvider,
            folderContentLoader: FolderContentLoader
        ) {
            self.path = path
            self.pageSize = pageSize
            self.apiConfigProvider = apiConfigProvider
            self.folderContentLoader = folderContentLoader
        }
        
        private let path: String
        private let pageSize: Int
        private let apiConfigProvider: ApiConfigProvider
        private let folderContentLoader: FolderContentLoader
        private var nextContinuationToken: String? = nil
        private var hasMore: Bool = true
        
        func next() async throws -> Element? {
//            return nil
            
            guard let apiConfig = apiConfigProvider.config, hasMore else {
                return nil
            }
            
            let result = try await folderContentLoader.getContent(
                path: path,
                continuationToken: nextContinuationToken,
                pageSize: pageSize,
                config: apiConfig
            )
            
            nextContinuationToken = result.nextContinuationToken
            hasMore = nextContinuationToken != nil
            
            let pageEntries = result.entries
            
            return pageEntries
        }
    }
}
