//
//  SdkEntryPageSequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class SdkEntryPageSequence: AsyncSequence {
    typealias AsyncIterator = PageIterator
    typealias Element = [Entry]
    
    typealias UnderlyingType = AnyAsyncSequence<S3ListObjectsPage>
    
    init(
        underlying: UnderlyingType,
        path: String,
        bucketName: String
    ) {
        self.underlying = underlying
        self.path = path
        self.bucketName = bucketName
    }
    
    private let underlying: UnderlyingType
    private let path: String
    private let bucketName: String
    
    func makeAsyncIterator() -> PageIterator {
        PageIterator(
            underlying: underlying.makeAsyncIterator(),
            path: path,
            bucketName: bucketName
        )
    }
    
    final class PageIterator: AsyncIteratorProtocol {
        init(
            underlying: UnderlyingType.AsyncIterator,
            path: String,
            bucketName: String,
            loadingStateSyncer: LoadingStateSyncer = LoadingStateSyncerImpl()
        ) {
            self.underlying = underlying
            self.path = path
            self.bucketName = bucketName
            self.loadingStateSyncer = loadingStateSyncer
        }
        
        private var underlying: UnderlyingType.AsyncIterator
        private let path: String
        private let bucketName: String
        private let loadingStateSyncer: LoadingStateSyncer
        
        func next() async throws -> Element? {
//            return nil
            
            guard let page: S3ListObjectsPage = try await underlying.next() else {
                return nil
            }
            
            let pageEntries: [Entry] = [
                page.commonPrefixes
                    .map { $0.prefix }
                    .filter { $0 != path }
                    .map {
                        Entry(
                            name: URL(fileURLWithPath: $0).lastPathComponent,
                            path: $0,
                            bucketName: bucketName,
                            isFolder: true,
                            loadingState: .notLoaded
                        )
                    },
                try await loadingStateSyncer.syncedLoadingStates(
                    for: page.contents
                        .filter { $0.key != path }
                        .map {
                            Entry(
                                name: URL(fileURLWithPath: $0.key).lastPathComponent,
                                path: $0.key,
                                bucketName: bucketName,
                                isFolder: false,
                                loadingState: .notLoaded
                            )
                        }
                )
            ]
                .compactMap { $0 }
                .flatMap { $0 }
                .sorted { $0.name < $1.name }
            
            return pageEntries
        }
    }
}
