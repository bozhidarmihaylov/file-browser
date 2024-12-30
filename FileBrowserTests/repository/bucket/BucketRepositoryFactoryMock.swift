//
//  BucketRepositoryFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import App

final class BucketRepositoryFactoryMock: BucketRepositoryFactory {
    private(set) var createBucketRepositoryCallCount: Int = 0
    
    var createBucketRepositoryResult: BucketRepository? = nil
    var createBucketRepositoryError: Error? = nil
    func createBucketRepository() throws -> BucketRepository? {
        createBucketRepositoryCallCount += 1
        
        if let error = createBucketRepositoryError {
            throw error
        }
        
        return createBucketRepositoryResult
    }
}
