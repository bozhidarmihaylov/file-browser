// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class S3StreamMock: S3Stream {

    //MARK: - readData

    var readDataThrowableError: Error?
    var readDataCallsCount = 0
    var readDataCalled: Bool {
        return readDataCallsCount > 0
    }
    var readDataReturnValue: Data?
    var readDataClosure: (() throws -> Data?)?

    func readData() throws -> Data? {
        if let error = readDataThrowableError {
            throw error
        }
        readDataCallsCount += 1
        return try readDataClosure.map({ try $0() }) ?? readDataReturnValue
    }

}
