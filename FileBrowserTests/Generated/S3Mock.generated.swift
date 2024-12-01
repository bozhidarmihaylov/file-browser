// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class S3Mock: S3 {

    //MARK: - listObjectsV2Paginated

    var listObjectsV2PaginatedInputCallsCount = 0
    var listObjectsV2PaginatedInputCalled: Bool {
        return listObjectsV2PaginatedInputCallsCount > 0
    }
    var listObjectsV2PaginatedInputReceivedInput: S3ListObjectsInput?
    var listObjectsV2PaginatedInputReceivedInvocations: [S3ListObjectsInput] = []
    var listObjectsV2PaginatedInputReturnValue: AnyAsyncSequence<S3ListObjectsPage>!
    var listObjectsV2PaginatedInputClosure: ((S3ListObjectsInput) -> AnyAsyncSequence<S3ListObjectsPage>)?

    func listObjectsV2Paginated(input: S3ListObjectsInput) -> AnyAsyncSequence<S3ListObjectsPage> {
        listObjectsV2PaginatedInputCallsCount += 1
        listObjectsV2PaginatedInputReceivedInput = input
        listObjectsV2PaginatedInputReceivedInvocations.append(input)
        return listObjectsV2PaginatedInputClosure.map({ $0(input) }) ?? listObjectsV2PaginatedInputReturnValue
    }

    //MARK: - getObject

    var getObjectInputThrowableError: Error?
    var getObjectInputCallsCount = 0
    var getObjectInputCalled: Bool {
        return getObjectInputCallsCount > 0
    }
    var getObjectInputReceivedInput: GetObjectInput?
    var getObjectInputReceivedInvocations: [GetObjectInput] = []
    var getObjectInputReturnValue: GetObjectOutput!
    var getObjectInputClosure: ((GetObjectInput) throws -> GetObjectOutput)?

    func getObject(input: GetObjectInput) throws -> GetObjectOutput {
        if let error = getObjectInputThrowableError {
            throw error
        }
        getObjectInputCallsCount += 1
        getObjectInputReceivedInput = input
        getObjectInputReceivedInvocations.append(input)
        return try getObjectInputClosure.map({ try $0(input) }) ?? getObjectInputReturnValue
    }

}
