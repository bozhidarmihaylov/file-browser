//
//  Entry+mock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

extension [Entry] {
    private static let mockBucketName = Bucket.mock.name
    static let mock = [
        Entry(
            name: "name1.ext1",
            path: "a/b/name1.ext1",
            bucketName: mockBucketName,
            isFolder: false,
            loadingState: .notLoaded
        ),
        Entry(
            name: "name2",
            path: "a/b/name2",
            bucketName: mockBucketName,
            isFolder: true,
            loadingState: .notLoaded
        ),
        Entry(
            name: "name3.ext2",
            path: "a/b/name3.ext2",
            bucketName: mockBucketName,
            isFolder: false,
            loadingState: .notLoaded
        )
    ]
}
