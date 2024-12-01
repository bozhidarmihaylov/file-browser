// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class LoadingRegistryMock: LoadingRegistry {

    //MARK: - registerTransfer

    var registerTransferThrowableError: Error?
    var registerTransferCallsCount = 0
    var registerTransferCalled: Bool {
        return registerTransferCallsCount > 0
    }
    var registerTransferReceivedTransfer: Transfer?
    var registerTransferReceivedInvocations: [Transfer] = []
    var registerTransferClosure: ((Transfer) throws -> Void)?

    func registerTransfer(_ transfer: Transfer) throws {
        if let error = registerTransferThrowableError {
            throw error
        }
        registerTransferCallsCount += 1
        registerTransferReceivedTransfer = transfer
        registerTransferReceivedInvocations.append(transfer)
        try registerTransferClosure?(transfer)
    }

    //MARK: - unregisterTransfer

    var unregisterTransferThrowableError: Error?
    var unregisterTransferCallsCount = 0
    var unregisterTransferCalled: Bool {
        return unregisterTransferCallsCount > 0
    }
    var unregisterTransferReceivedTransfer: Transfer?
    var unregisterTransferReceivedInvocations: [Transfer] = []
    var unregisterTransferClosure: ((Transfer) throws -> Void)?

    func unregisterTransfer(_ transfer: Transfer) throws {
        if let error = unregisterTransferThrowableError {
            throw error
        }
        unregisterTransferCallsCount += 1
        unregisterTransferReceivedTransfer = transfer
        unregisterTransferReceivedInvocations.append(transfer)
        try unregisterTransferClosure?(transfer)
    }

    //MARK: - unregisterTransfer

    var unregisterTransferTaskIdThrowableError: Error?
    var unregisterTransferTaskIdCallsCount = 0
    var unregisterTransferTaskIdCalled: Bool {
        return unregisterTransferTaskIdCallsCount > 0
    }
    var unregisterTransferTaskIdReceivedTaskId: Int?
    var unregisterTransferTaskIdReceivedInvocations: [Int] = []
    var unregisterTransferTaskIdClosure: ((Int) throws -> Void)?

    func unregisterTransfer(taskId: Int) throws {
        if let error = unregisterTransferTaskIdThrowableError {
            throw error
        }
        unregisterTransferTaskIdCallsCount += 1
        unregisterTransferTaskIdReceivedTaskId = taskId
        unregisterTransferTaskIdReceivedInvocations.append(taskId)
        try unregisterTransferTaskIdClosure?(taskId)
    }

    //MARK: - dowloadingState

    var dowloadingStateForInThrowableError: Error?
    var dowloadingStateForInCallsCount = 0
    var dowloadingStateForInCalled: Bool {
        return dowloadingStateForInCallsCount > 0
    }
    var dowloadingStateForInReceivedArguments: (relativeFilePath: String, bucketName: String)?
    var dowloadingStateForInReceivedInvocations: [(relativeFilePath: String, bucketName: String)] = []
    var dowloadingStateForInReturnValue: LoadingState!
    var dowloadingStateForInClosure: ((String, String) throws -> LoadingState)?

    func dowloadingState(for relativeFilePath: String, in bucketName: String) throws -> LoadingState {
        if let error = dowloadingStateForInThrowableError {
            throw error
        }
        dowloadingStateForInCallsCount += 1
        dowloadingStateForInReceivedArguments = (relativeFilePath: relativeFilePath, bucketName: bucketName)
        dowloadingStateForInReceivedInvocations.append((relativeFilePath: relativeFilePath, bucketName: bucketName))
        return try dowloadingStateForInClosure.map({ try $0(relativeFilePath, bucketName) }) ?? dowloadingStateForInReturnValue
    }

    //MARK: - downloadingStates

    var downloadingStatesForInThrowableError: Error?
    var downloadingStatesForInCallsCount = 0
    var downloadingStatesForInCalled: Bool {
        return downloadingStatesForInCallsCount > 0
    }
    var downloadingStatesForInReceivedArguments: (relativeFilePaths: [String], bucketName: String)?
    var downloadingStatesForInReceivedInvocations: [(relativeFilePaths: [String], bucketName: String)] = []
    var downloadingStatesForInReturnValue: [LoadingState]!
    var downloadingStatesForInClosure: (([String], String) throws -> [LoadingState])?

    func downloadingStates(for relativeFilePaths: [String], in bucketName: String) throws -> [LoadingState] {
        if let error = downloadingStatesForInThrowableError {
            throw error
        }
        downloadingStatesForInCallsCount += 1
        downloadingStatesForInReceivedArguments = (relativeFilePaths: relativeFilePaths, bucketName: bucketName)
        downloadingStatesForInReceivedInvocations.append((relativeFilePaths: relativeFilePaths, bucketName: bucketName))
        return try downloadingStatesForInClosure.map({ try $0(relativeFilePaths, bucketName) }) ?? downloadingStatesForInReturnValue
    }

}
