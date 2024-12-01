//
//  FileTransferPlacer.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileTransferPlacer {
    func placeTransfer(
        _ transfer: Transfer,
        from temporaryUrl: URL
    ) throws
}

struct FileTransferPlacerImpl: FileTransferPlacer {
    init(
        localUrlFinder: LocalUrlFinder = LocalUrlFinderImpl.shared,
        fileSystem: FileSystem = FileSystemImpl.shared
    ) {
        self.localUrlFinder = localUrlFinder
        self.fileSystem = fileSystem
    }
    
    private let localUrlFinder: LocalUrlFinder
    private let fileSystem: FileSystem
    
    func placeTransfer(
        _ transfer: Transfer,
        from temporaryUrl: URL
    ) throws {
        let localUrl = localUrlFinder.localUrl(
            for: transfer.relativeFilePath,
            in: transfer.bucketName
        )
        
        let parentPath = localUrl.deletingLastPathComponent().path
        
        var isDirectory: ObjCBool = false
        if !fileSystem.fileExists(atPath: parentPath, isDirectory: &isDirectory) {
            try fileSystem.createDirectory(atPath: parentPath, withIntermediateDirectories: true)
        } else if !isDirectory.boolValue {
            throw BucketRepositoryError.parentIsFile
        }
        
        try fileSystem.moveFile(
            at: temporaryUrl,
            to: localUrl
        )
    }
}
