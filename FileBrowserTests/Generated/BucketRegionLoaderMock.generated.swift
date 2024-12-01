// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class BucketRegionLoaderMock: BucketRegionLoader {

    //MARK: - loadRegion

    var loadRegionWithThrowableError: Error?
    var loadRegionWithCallsCount = 0
    var loadRegionWithCalled: Bool {
        return loadRegionWithCallsCount > 0
    }
    var loadRegionWithReceivedBucketName: String?
    var loadRegionWithReceivedInvocations: [String] = []
    var loadRegionWithReturnValue: String!
    var loadRegionWithClosure: ((String) throws -> String)?

    func loadRegion(with bucketName: String) throws -> String {
        if let error = loadRegionWithThrowableError {
            throw error
        }
        loadRegionWithCallsCount += 1
        loadRegionWithReceivedBucketName = bucketName
        loadRegionWithReceivedInvocations.append(bucketName)
        return try loadRegionWithClosure.map({ try $0(bucketName) }) ?? loadRegionWithReturnValue
    }

}
