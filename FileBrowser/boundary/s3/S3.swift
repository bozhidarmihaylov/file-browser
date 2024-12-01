//
//  S3.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol S3 {
    func listObjectsV2Paginated(input: S3ListObjectsInput) -> AnyAsyncSequence<S3ListObjectsPage>
    func getObject(input: GetObjectInput) async throws -> GetObjectOutput
}

// GetObject

struct GetObjectInput {
    let bucketName: String
    let key: String
}

struct GetObjectOutput {
    let body: S3Stream?
}

// sourcery: AutoMockable
protocol S3Stream {
    func readData() async throws -> Data?
}

// ListObjects

struct S3ListObjectsInput {
    let bucketName: String
    let delimiter: String
    let prefix: String
    let pageSize: Int
}

struct S3ListObjectsPage {
    let commonPrefixes: [S3Prefix]
    let contents: [S3Object]
}

struct S3Prefix {
    let prefix: String
}

struct S3Object {
    let key: String
    let sizeBytes: Int
    let updateDate: Date
}
