//
//  BucketRepositoryFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import App

final class BucketRepositoryFactoryMock: BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository? {
        nil
    }
}
