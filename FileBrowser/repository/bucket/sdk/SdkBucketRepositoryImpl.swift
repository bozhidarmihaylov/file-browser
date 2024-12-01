//
//  SdkBucketRepositoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class SdkBucketRepositoryImpl: BucketRepository {
    init(
        bucketName: String,
        s3: S3,
        fileSystem: FileSystem,
        localUrlFinder: LocalUrlFinder,
        loadingRegistry: LoadingRegistry
    ) {
        self.bucketName = bucketName
        self.s3 = s3
        self.fileSystem = fileSystem
        self.localUrlFinder = localUrlFinder
        self.loadingRegistry = loadingRegistry
    }
        
    private let bucketName: String
    private let s3: S3
    private let fileSystem: FileSystem
    private let localUrlFinder: LocalUrlFinder
    private let loadingRegistry: LoadingRegistry
    
    func getContent(
        path: String
    ) -> AnyAsyncSequence<[Entry]> {
        let input = S3ListObjectsInput(
            bucketName: bucketName,
            delimiter: "/",
            prefix: path,
            pageSize: Copy.pageSize
        )
        
        let underlying = s3.listObjectsV2Paginated(input: input)
        var result = SdkEntryPageSequence(
            underlying: underlying,
            path: path,
            bucketName: bucketName
        )
        
        return AnyAsyncSequence(sequence: &result)
    }
    
    func downloadFile(
        path: String
    ) async throws -> Entry {
        let localUrl = localUrlFinder.localUrl(for: path, in: bucketName)
        let transfer = Transfer(
            relativeFilePath: path,
            bucketName: bucketName,
            taskIdentifier: 0
        )
        
        do {
            try await loadingRegistry.registerTransfer(transfer)
            
            let input = GetObjectInput(
                bucketName: bucketName,
                key: path
            )
            
            let output = try await s3.getObject(input: input)
            
            guard let body = output.body else {
                throw BucketRepositoryError.noData
            }
            
            guard let data = try await body.readData() else {
                throw BucketRepositoryError.errorData
            }
            
            let parentPath = localUrl.deletingLastPathComponent().path
            
            var isDirectory: ObjCBool = false
            if !fileSystem.fileExists(atPath: parentPath, isDirectory: &isDirectory) {
                try fileSystem.createDirectory(atPath: parentPath, withIntermediateDirectories: true)
            } else if !isDirectory.boolValue {
                throw BucketRepositoryError.parentIsFile
            }
            
            try data.write(to: localUrl, options: [.atomic])
            
            try await loadingRegistry.unregisterTransfer(transfer)
        } catch {
            try await loadingRegistry.unregisterTransfer(transfer)
            throw error
        }
        
        return Entry(
            name: localUrl.lastPathComponent,
            path: path,
            bucketName: bucketName,
            isFolder: false,
            loadingState: try await loadingRegistry.dowloadingState(for: path, in: bucketName)
        )
    }
    
    private enum Copy {
        static let pageSize = 20
    }
}
