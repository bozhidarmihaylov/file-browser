//
//  BucketRepositoryFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository?
}

struct BucketRepositoryFactoryImpl: BucketRepositoryFactory {
    init(
        configProvider: ApiConfigProvider,
        s3ClientFactory: S3ClientFactory
    ) {
        self.configProvider = configProvider
        self.s3ClientFactory = s3ClientFactory
    }
    
    private let configProvider: ApiConfigProvider
    private let s3ClientFactory: S3ClientFactory
    
    func createBucketRepository() throws -> BucketRepository? {
        guard let config = configProvider.config else {
            return nil
        }
        
        let s3Client = try s3ClientFactory.createAwsClient(config: config)
        
        return BucketRepositoryImpl(
            bucketName: config.bucket.name,
            s3Client: s3Client
        )
    }
    
    static let shared: BucketRepositoryFactory = BucketRepositoryFactoryImpl(
        configProvider: ApiConfigStoreImpl.shared,
        s3ClientFactory: S3ClientFactoryImpl()
    )
}
