//
//  S3ClientFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import AWSS3
import AWSSDKIdentity

protocol S3ClientFactory {
    func createAwsClient(config: ApiConfig) throws -> AWSS3.S3Client
}

struct S3ClientFactoryImpl: S3ClientFactory {
    func createAwsClient(config: ApiConfig) throws -> AWSS3.S3Client {
        let credential = AWSSDKIdentity.AWSCredentialIdentity(
            accessKey: config.credential.accessKey,
            secret: config.credential.secretKey
        )
        
        let resolver = try StaticAWSCredentialIdentityResolver(credential)
        let cfg = try AWSS3.S3Client.S3ClientConfiguration(
            awsCredentialIdentityResolver: resolver,
            region: config.bucket.region,
            signingRegion: config.bucket.region
        )
        
        let client = AWSS3.S3Client(config: cfg)
        return client
    }
}
