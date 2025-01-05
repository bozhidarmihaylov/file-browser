//
//  Entry+mock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

fileprivate let mockBucketName = Bucket.mock.name

extension Entry {
    static let fileMock = Entry(
        name: "name1.ext1",
        path: "a/b/name1.ext1",
        bucketName: mockBucketName,
        isFolder: false,
        loadingState: .notLoaded
    )
    
    static let folderMock = Entry(
        name: "name2",
        path: "a/b/name2",
        bucketName: mockBucketName,
        isFolder: true,
        loadingState: .notLoaded
    )
}


extension [Entry] {
    static let mock = [
        Entry.fileMock,
        Entry.folderMock,
        Entry(
            name: "name3.ext2",
            path: "a/b/name3.ext2",
            bucketName: mockBucketName,
            isFolder: false,
            loadingState: .notLoaded
        )
    ]
}
