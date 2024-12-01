//
//  S3Impl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import AWSS3
import enum Smithy.ByteStream

struct S3Impl: S3 {
    init(
        s3Client: AWSS3.S3Client
    ) {
        self.s3Client = s3Client
    }

    private let s3Client: AWSS3.S3Client
    
    func listObjectsV2Paginated(input: S3ListObjectsInput) -> AnyAsyncSequence<S3ListObjectsPage> {
        let s3Input = ListObjectsV2Input(
            bucket: input.bucketName,
            delimiter: input.delimiter,
            maxKeys: input.pageSize,
            prefix: input.prefix
        )
        let underlying = s3Client.listObjectsV2Paginated(
            input: s3Input
        )
        var sequence = S3ListObjectsSequenceImpl(
            underlying: underlying
        )
        let result = AnyAsyncSequence(
            sequence: &sequence
        )

        return result
    }
    
    func getObject(input: GetObjectInput) async throws -> GetObjectOutput {
        let input = AWSS3.GetObjectInput(
            bucket: input.bucketName,
            key: input.key
        )
        
        let output = try await s3Client.getObject(input: input)
        
        return GetObjectOutput(
            body: output.body.map(S3StreamImpl.init)
        )
    }
}

struct S3StreamImpl: S3Stream {
    init(stream: ByteStream) {
        self.stream = stream
    }
    private let stream: ByteStream
    
    func readData() async throws -> Data? {
        try await stream.readData()
    }
}
