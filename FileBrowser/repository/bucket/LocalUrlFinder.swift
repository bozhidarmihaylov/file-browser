//
//  LocalUrlFinder.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol LocalUrlFinder {
    func localUrl(
        for relativeFilePath: String,
        in bucketName: String
    ) -> URL
}

extension LocalUrlFinder {
    func localPath(
        for relativeFilePath: String,
        in bucketName: String
    ) -> String {
        localUrl(for: relativeFilePath, in: bucketName)
            .path(percentEncoded: false)
    }
}

struct LocalUrlFinderImpl: LocalUrlFinder {
    static let shared: LocalUrlFinder = LocalUrlFinderImpl()
    
    init(
        fileSystem: FileSystem = FileSystemImpl()
    ) {
        self.fileSystem = fileSystem
    }
    
    private let fileSystem: FileSystem
    
    private func rootUrl(for bucketName: String) -> URL {
        fileSystem.documentsDirectoryUrl
            .appendingPathComponent(bucketName)
    }
        
    func localUrl(
        for relativeFilePath: String,
        in bucketName: String
    ) -> URL {
        rootUrl(for: bucketName)
            .appendingPathComponent(relativeFilePath)

    }
}
