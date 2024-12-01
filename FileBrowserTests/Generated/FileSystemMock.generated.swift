// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileSystemMock: FileSystem {
    var documentsDirectoryUrl: URL {
        get { return underlyingDocumentsDirectoryUrl }
        set(value) { underlyingDocumentsDirectoryUrl = value }
    }
    var underlyingDocumentsDirectoryUrl: URL!
    var temporaryDirectoryUrl: URL {
        get { return underlyingTemporaryDirectoryUrl }
        set(value) { underlyingTemporaryDirectoryUrl = value }
    }
    var underlyingTemporaryDirectoryUrl: URL!

    //MARK: - fileExists

    var fileExistsAtPathCallsCount = 0
    var fileExistsAtPathCalled: Bool {
        return fileExistsAtPathCallsCount > 0
    }
    var fileExistsAtPathReceivedPath: String?
    var fileExistsAtPathReceivedInvocations: [String] = []
    var fileExistsAtPathReturnValue: Bool!
    var fileExistsAtPathClosure: ((String) -> Bool)?

    func fileExists(atPath path: String) -> Bool {
        fileExistsAtPathCallsCount += 1
        fileExistsAtPathReceivedPath = path
        fileExistsAtPathReceivedInvocations.append(path)
        return fileExistsAtPathClosure.map({ $0(path) }) ?? fileExistsAtPathReturnValue
    }

    //MARK: - fileExists

    var fileExistsAtPathIsDirectoryCallsCount = 0
    var fileExistsAtPathIsDirectoryCalled: Bool {
        return fileExistsAtPathIsDirectoryCallsCount > 0
    }
    var fileExistsAtPathIsDirectoryReceivedArguments: (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>)?
    var fileExistsAtPathIsDirectoryReceivedInvocations: [(path: String, isDirectory: UnsafeMutablePointer<ObjCBool>)] = []
    var fileExistsAtPathIsDirectoryReturnValue: Bool!
    var fileExistsAtPathIsDirectoryClosure: ((String, UnsafeMutablePointer<ObjCBool>) -> Bool)?

    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool {
        fileExistsAtPathIsDirectoryCallsCount += 1
        fileExistsAtPathIsDirectoryReceivedArguments = (path: path, isDirectory: isDirectory)
        fileExistsAtPathIsDirectoryReceivedInvocations.append((path: path, isDirectory: isDirectory))
        return fileExistsAtPathIsDirectoryClosure.map({ $0(path, isDirectory) }) ?? fileExistsAtPathIsDirectoryReturnValue
    }

    //MARK: - createDirectory

    var createDirectoryAtPathWithIntermediateDirectoriesThrowableError: Error?
    var createDirectoryAtPathWithIntermediateDirectoriesCallsCount = 0
    var createDirectoryAtPathWithIntermediateDirectoriesCalled: Bool {
        return createDirectoryAtPathWithIntermediateDirectoriesCallsCount > 0
    }
    var createDirectoryAtPathWithIntermediateDirectoriesReceivedArguments: (path: String, createIntermediates: Bool)?
    var createDirectoryAtPathWithIntermediateDirectoriesReceivedInvocations: [(path: String, createIntermediates: Bool)] = []
    var createDirectoryAtPathWithIntermediateDirectoriesClosure: ((String, Bool) throws -> Void)?

    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {
        if let error = createDirectoryAtPathWithIntermediateDirectoriesThrowableError {
            throw error
        }
        createDirectoryAtPathWithIntermediateDirectoriesCallsCount += 1
        createDirectoryAtPathWithIntermediateDirectoriesReceivedArguments = (path: path, createIntermediates: createIntermediates)
        createDirectoryAtPathWithIntermediateDirectoriesReceivedInvocations.append((path: path, createIntermediates: createIntermediates))
        try createDirectoryAtPathWithIntermediateDirectoriesClosure?(path, createIntermediates)
    }

    //MARK: - moveFile

    var moveFileAtToThrowableError: Error?
    var moveFileAtToCallsCount = 0
    var moveFileAtToCalled: Bool {
        return moveFileAtToCallsCount > 0
    }
    var moveFileAtToReceivedArguments: (atUrl: URL, toUrl: URL)?
    var moveFileAtToReceivedInvocations: [(atUrl: URL, toUrl: URL)] = []
    var moveFileAtToClosure: ((URL, URL) throws -> Void)?

    func moveFile(at atUrl: URL, to toUrl: URL) throws {
        if let error = moveFileAtToThrowableError {
            throw error
        }
        moveFileAtToCallsCount += 1
        moveFileAtToReceivedArguments = (atUrl: atUrl, toUrl: toUrl)
        moveFileAtToReceivedInvocations.append((atUrl: atUrl, toUrl: toUrl))
        try moveFileAtToClosure?(atUrl, toUrl)
    }

}
