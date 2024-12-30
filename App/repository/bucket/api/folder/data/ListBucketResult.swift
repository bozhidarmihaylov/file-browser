//
//  ListBucketResult.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ListBucketResult: Decodable, Equatable {
    let name: String
    let prefix: String
    let continuationToken: String?
    let nextContinuationToken: String?
    let keyCount: Int
    let maxKeys: Int
    let delimiter: String
    let isTruncated: Bool
    let contents: [Contents]
    let commonPrefixes: [Prefix]
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case prefix = "Prefix"
        case continuationToken = "ContinuationToken"
        case nextContinuationToken = "NextContinuationToken"
        case keyCount = "KeyCount"
        case maxKeys = "MaxKeys"
        case delimiter = "Delimiter"
        case isTruncated = "IsTruncated"
        case contents = "Contents"
        case commonPrefixes = "CommonPrefixes"
    }
    
    struct Contents: Decodable, Equatable {
        let key: String
        let lastModified: Date
        let etag: String
        let size: Int64
        let storageClass: String
        
        enum CodingKeys: String, CodingKey {
            case key = "Key"
            case lastModified = "LastModified"
            case etag = "ETag"
            case size = "Size"
            case storageClass = "StorageClass"
        }
    }

    struct Prefix: Decodable, Equatable {
        let prefix: String
        
        enum CodingKeys: String, CodingKey {
            case prefix = "Prefix"
        }
    }
}
