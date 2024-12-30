//
//  FileSystemRepository.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol BucketRepository {
    func getContent(
        path: String
    ) -> AnyAsyncSequence<[Entry]>
    
    func downloadFile(
        path: String
    ) async throws -> Entry
}

enum BucketRepositoryError: Error {
    case noData
    case errorData
    case parentIsFile
    case noConfig
}
