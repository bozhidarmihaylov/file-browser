//
//  BucketRegionLoader.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol BucketRegionLoader {
    func loadRegion(with bucketName: String) async throws -> String
}

enum BucketRegionLoaderError: Swift.Error, Equatable {
    case invalidBucketName
    case notFound
}

struct BucketRegionLoaderImpl: BucketRegionLoader {
    static let shared: BucketRegionLoader = BucketRegionLoaderImpl(
        httpClient: HttpClientImpl.shared
    )

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    private let httpClient: HttpClient
    
    func loadRegion(with bucketName: String) async throws -> String {
        guard let url = URL(
            string: Copy.urlStringWithBucketName(bucketName)
        ) else {
            throw BucketRegionLoaderError.invalidBucketName
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Copy.head
        
        let (_, response) = try await httpClient.data(for: request)

        guard let result = (response as? HTTPURLResponse)?
            .value(forHTTPHeaderField: Copy.regionHeaderName)
        else {
            throw BucketRegionLoaderError.notFound
        }
        
        return result
    }
    
    private enum Copy {
        static let head = "HEAD"
        static let regionHeaderName = "x-amz-bucket-region"
        
        static func urlStringWithBucketName(_ bucketName: String) -> String {
            "https://\(bucketName).s3.amazonaws.com"
        }
    }
}
