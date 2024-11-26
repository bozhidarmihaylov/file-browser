//
//  EntryPageSequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import ClientRuntime
import AWSS3

final class EntryPageSequence: AsyncSequence {
    typealias AsyncIterator = PageIterator
    typealias Element = [Entry]
    
    typealias UnderlyingType = ClientRuntime.PaginatorSequence<ListObjectsV2Input, ListObjectsV2Output>
    
    init(
        underlying: UnderlyingType,
        path: String,
        rootUrl: URL
    ) {
        self.underlying = underlying
        self.path = path
        self.rootUrl = rootUrl
    }
    
    private let underlying: UnderlyingType
    private let path: String
    private let rootUrl: URL
    
    func makeAsyncIterator() -> PageIterator {
        PageIterator(
            underlying: underlying.makeAsyncIterator(),
            path: path,
            rootUrl: rootUrl
        )
    }
    
    final class PageIterator: AsyncIteratorProtocol {
        init(
            underlying: UnderlyingType.PaginationIterator,
            path: String,
            rootUrl: URL
        ) {
            self.underlying = underlying
            self.path = path
            self.rootUrl = rootUrl
        }
        
        var underlying: UnderlyingType.PaginationIterator
        let path: String
        let rootUrl: URL
        
        private func localUrl(path: String) -> URL {
            rootUrl
                .appendingPathComponent(path)
        }
        
        func next() async throws -> Element? {
//            return nil
            
            guard let page = try await underlying.next() else {
                return nil
            }
            
            let pageEntries: [Entry] = [
                page.commonPrefixes?
                    .compactMap { $0.prefix }
                    .filter { $0 != path }
                    .map {
                        Entry(
                            name: URL(fileURLWithPath: $0).lastPathComponent,
                            path: $0,
                            localUrl: localUrl(path: $0),
                            isFolder: true,
                            isDownloaded: false
                        )
                    },
                page.contents?
                    .filter { $0.key != nil }
                    .filter { $0.key != path }
                    .map {
                        Entry(
                            name: URL(fileURLWithPath: $0.key!).lastPathComponent,
                            path: $0.key!,
                            localUrl: localUrl(path: $0.key!),
                            isFolder: false,
                            isDownloaded: FileManager.default.fileExists(atPath: localUrl(path: $0.key!).path)
                        )
                    }
            ]
                .compactMap { $0 }
                .flatMap { $0 }
            
            return pageEntries
        }
    }
}
