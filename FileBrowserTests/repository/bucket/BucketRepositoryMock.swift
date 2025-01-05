//
//  BucketRepositoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class BucketRepositoryMock: BucketRepository {
    private(set) var getContentWithPathCalls: [String] = []
    
    var getContentWithPathResult: AnyAsyncSequence<[Entry]>! = nil
    func getContent(path: String) -> AnyAsyncSequence<[Entry]> {
        getContentWithPathCalls.append(path)
        
        return getContentWithPathResult
    }
    
    private(set) var downloadFileWithPathCalls: [String] = []
    
    var downloadFileWithPathResult: Entry! = nil
    var downloadFileWithPathError: Error? = nil
    func downloadFile(path: String) async throws -> Entry {
        downloadFileWithPathCalls.append(path)
        
        if let error = downloadFileWithPathError {
            throw error
        }
        
        return downloadFileWithPathResult
    }
}
