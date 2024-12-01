//
//  S3FactoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct S3FactoryImpl: S3Factory {
    static let shared: S3Factory = S3FactoryImpl(
        clientFactory: S3ClientFactoryImpl()
    )
    
    init(clientFactory: S3ClientFactory) {
        self.clientFactory = clientFactory
    }
    
    let clientFactory: S3ClientFactory
    
    func createS3(config: ApiConfig) throws -> S3 {
        S3Impl(
            s3Client: try clientFactory.createAwsClient(config: config)
        )
    }
    
}
