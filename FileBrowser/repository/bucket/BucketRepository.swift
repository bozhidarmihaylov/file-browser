//
//  FileSystemRepository.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import AWSS3
import AWSSDKIdentity

struct Entry {
    let name: String
    let path: String
    let localUrl: URL
    let isFolder: Bool
    let isDownloaded: Bool
}

protocol BucketRepository {
    func getContent(
        path: String
    ) -> EntryPageSequence
    
    func downloadFile(
        path: String
    ) async throws -> Entry
    
    func isDownloadingFile(path: String) -> Bool
}

enum BucketRepositoryError: Swift.Error {
    case noData
    case errorData
    case parentIsFile
}

final class BucketRepositoryImpl: BucketRepository {
    init(
        bucketName: String,
        s3Client: AWSS3.S3Client
    ) {
        self.bucketName = bucketName
        self.s3Client = s3Client
    }
        
    private let bucketName: String
    private let s3Client: AWSS3.S3Client
    
    private var documentsDirectoryUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var rootUrl: URL {
        documentsDirectoryUrl
            .appendingPathComponent(bucketName)
    }
    
    private func localUrl(path: String) -> URL {
        rootUrl
            .appendingPathComponent(path)
    }
    
    func getContent(
        path: String
    ) -> EntryPageSequence {
        let input = ListObjectsV2Input(
            bucket: bucketName,
            delimiter: "/",
            prefix: path
        )
        
        let underlying = s3Client.listObjectsV2Paginated(input: input)
        let result = EntryPageSequence(
            underlying: underlying,
            path: path,
            rootUrl: rootUrl
        )
        return result
    }
    
    func downloadFile(
        path: String
    ) async throws -> Entry {
        setDownloadingFile(true, path: path)
        defer { setDownloadingFile(false, path: path) }
        
        let input = GetObjectInput(
            bucket: bucketName,
            key: path
        )
        
        let output = try await s3Client.getObject(input: input)

        guard let body = output.body else {
            throw BucketRepositoryError.noData
        }

        guard let data = try await body.readData() else {
            throw BucketRepositoryError.errorData
        }

        let localUrl = localUrl(path: path)
        
        let parentPath = localUrl.deletingLastPathComponent().path
        
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: parentPath, isDirectory: &isDirectory) {
            try fileManager.createDirectory(atPath: parentPath, withIntermediateDirectories: true)
        } else if !isDirectory.boolValue {
            throw BucketRepositoryError.parentIsFile
        }
        
        try data.write(to: localUrl, options: [.atomic])
        
        return Entry(
            name: localUrl.lastPathComponent,
            path: path,
            localUrl: localUrl,
            isFolder: false,
            isDownloaded: FileManager.default.fileExists(atPath: localUrl.path)
        )
    }
    
    private let lock = NSRecursiveLock()
    private var downloadsInProgress: Set<String> = Set()
    
    func isDownloadingFile(path: String) -> Bool {
        lock.withLock {
            downloadsInProgress.contains(path)
        }
    }
    private func setDownloadingFile(_ isDownloading: Bool, path: String) {
        lock.withLock {
            if isDownloading {
                downloadsInProgress.insert(path)
            } else {
                downloadsInProgress.remove(path)
            }
        }
    }
}

