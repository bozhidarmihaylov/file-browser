// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class BucketRepositoryFactoryMock: BucketRepositoryFactory {

    //MARK: - createBucketRepository

    var createBucketRepositoryThrowableError: Error?
    var createBucketRepositoryCallsCount = 0
    var createBucketRepositoryCalled: Bool {
        return createBucketRepositoryCallsCount > 0
    }
    var createBucketRepositoryReturnValue: BucketRepository?
    var createBucketRepositoryClosure: (() throws -> BucketRepository?)?

    func createBucketRepository() throws -> BucketRepository? {
        if let error = createBucketRepositoryThrowableError {
            throw error
        }
        createBucketRepositoryCallsCount += 1
        return try createBucketRepositoryClosure.map({ try $0() }) ?? createBucketRepositoryReturnValue
    }

}
