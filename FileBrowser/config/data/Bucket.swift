//
//  Bucket.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol Bucket {
    var name: String { get }
    var region: String { get }
}

struct BucketImpl: Bucket, Codable {
    var name: String
    var region: String
}
