//
//  BucketRepositoryFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import FileBrowser

final class BucketRepositoryFactoryMock: BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository? {
        nil
    }
}
