//
//  S3ListObjectsSequenceImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import AWSS3
import ClientRuntime

final class S3ListObjectsSequenceImpl: S3ListObjectsSequence {
    typealias Element = S3ListObjectsPage
    typealias AsyncIterator = PageIterator
    
    typealias UnderlyingType = ClientRuntime.PaginatorSequence<ListObjectsV2Input, ListObjectsV2Output>
    
    init(
        underlying: UnderlyingType
    ) {
        self.underlying = underlying
    }
    
    private let underlying: UnderlyingType
    
    func makeAsyncIterator() -> PageIterator {
        PageIterator(
            underlying: underlying.makeAsyncIterator()
        )
    }
    
    final class PageIterator: AsyncIteratorProtocol {
        init(
            underlying: UnderlyingType.PaginationIterator
        ) {
            self.underlying = underlying
        }
        
        var underlying: UnderlyingType.PaginationIterator
        
        func next() async throws -> Element? {
            guard let page = try await underlying.next() else {
                return nil
            }
            
            let result: S3ListObjectsPage = S3ListObjectsPage(
                commonPrefixes: page.commonPrefixes?
                    .compactMap(\.prefix)
                    .map(S3Prefix.init)
                ?? [],
                contents: page.contents?
                    .compactMap { $0.toOurS3Object() }
                ?? []
            )
            
            return result
        }
    }
}

extension S3ClientTypes.Object {
    func toOurS3Object() -> S3Object? {
        guard let key,
              let size,
              let lastModified 
        else { return nil }
        
        return S3Object(
            key: key,
            sizeBytes: size,
            updateDate: lastModified
        )
    }
}
