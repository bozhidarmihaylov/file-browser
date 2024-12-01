// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class BucketRepositoryMock: BucketRepository {

    //MARK: - getContent

    var getContentPathCallsCount = 0
    var getContentPathCalled: Bool {
        return getContentPathCallsCount > 0
    }
    var getContentPathReceivedPath: String?
    var getContentPathReceivedInvocations: [String] = []
    var getContentPathReturnValue: AnyAsyncSequence<[Entry]>!
    var getContentPathClosure: ((String) -> AnyAsyncSequence<[Entry]>)?

    func getContent(path: String) -> AnyAsyncSequence<[Entry]> {
        getContentPathCallsCount += 1
        getContentPathReceivedPath = path
        getContentPathReceivedInvocations.append(path)
        return getContentPathClosure.map({ $0(path) }) ?? getContentPathReturnValue
    }

    //MARK: - downloadFile

    var downloadFilePathThrowableError: Error?
    var downloadFilePathCallsCount = 0
    var downloadFilePathCalled: Bool {
        return downloadFilePathCallsCount > 0
    }
    var downloadFilePathReceivedPath: String?
    var downloadFilePathReceivedInvocations: [String] = []
    var downloadFilePathReturnValue: Entry!
    var downloadFilePathClosure: ((String) throws -> Entry)?

    func downloadFile(path: String) throws -> Entry {
        if let error = downloadFilePathThrowableError {
            throw error
        }
        downloadFilePathCallsCount += 1
        downloadFilePathReceivedPath = path
        downloadFilePathReceivedInvocations.append(path)
        return try downloadFilePathClosure.map({ try $0(path) }) ?? downloadFilePathReturnValue
    }

}
