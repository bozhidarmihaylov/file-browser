//
//  SdkBucketRepositoryFactoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct SdkBucketRepositoryFactoryImpl: BucketRepositoryFactory {
    static let shared: BucketRepositoryFactory = SdkBucketRepositoryFactoryImpl(
        configProvider: ApiConfigStoreImpl.shared,
        s3Factory: S3FactoryImpl.shared,
        fileSystem: FileSystemImpl.shared,
        localUrlFinder: LocalUrlFinderImpl.shared,
        loadingRegistry: LoadingRegistryImpl.shared
    )
    
    init(
        configProvider: ApiConfigProvider,
        s3Factory: S3Factory,
        fileSystem: FileSystem,
        localUrlFinder: LocalUrlFinder,
        loadingRegistry: LoadingRegistry
    ) {
        self.configProvider = configProvider
        self.s3Factory = s3Factory
        self.fileSystem = fileSystem
        self.localUrlFinder = localUrlFinder
        self.loadingRegistry = loadingRegistry
    }
    
    private let configProvider: ApiConfigProvider
    private let s3Factory: S3Factory
    private let fileSystem: FileSystem
    private let localUrlFinder: LocalUrlFinder
    private let loadingRegistry: LoadingRegistry
    
    func createBucketRepository() throws -> BucketRepository? {
        guard let config = configProvider.config else {
            return nil
        }
        
        let s3 = try s3Factory.createS3(config: config)
        
        return SdkBucketRepositoryImpl(
            bucketName: config.bucket.name,
            s3: s3,
            fileSystem: fileSystem,
            localUrlFinder: localUrlFinder,
            loadingRegistry: loadingRegistry
        )
    }
}
