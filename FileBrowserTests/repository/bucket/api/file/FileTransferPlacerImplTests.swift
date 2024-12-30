//
//  FileTransferPlacerImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileTransferPlacerImplTests: XCTestCase {
    func testPlaceTransfer_parentDirectoryExistsAndMoveSuccessful_success() throws {
        let (sut, _, _) = createSut(
            directoryState: .exists(isDirectory: true),
            hasFileMoveError: false
        )
        
        do {
            try sut.placeTransfer(Copy.testTransfer, from: Copy.tempFileUrl)
        } catch {
            XCTFail("Parent directory exists and move successful but error thrown: \(error)")
        }
    }
    
    func testPlaceTransfer_parentCreationSuccessAndMoveSuccessful_success() throws {
        let (sut, _, _) = createSut(
            directoryState: .notExists(hasCreateError: false),
            hasFileMoveError: false
        )
        
        do {
            try sut.placeTransfer(Copy.testTransfer, from: Copy.tempFileUrl)
        } catch {
            XCTFail("Parent directory exists and move successful but error thrown: \(error)")
        }
    }
    
    func testPlaceTransfer_parentDirectoryExistsAndErrorMoving_errorReturned() throws {
        let (sut, _, _) = createSut(
            directoryState: .notExists(hasCreateError: false),
            hasFileMoveError: true
        )
        
        XCTAssertThrowsError(
            try sut.placeTransfer(Copy.testTransfer, from: Copy.tempFileUrl)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.moveFileError)
        }
    }
    
    func testPlaceTransfer_parentDirectoryCreationFailed_errorReturned() throws {
        let (sut, _, fileSystemMock) = createSut(
            directoryState: .notExists(hasCreateError: true),
            hasFileMoveError: true
        )
        
        XCTAssertThrowsError(
            try sut.placeTransfer(Copy.testTransfer, from: Copy.tempFileUrl)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.createDirectoryError)
        }
        XCTAssertEqual(fileSystemMock.moveFileAtUrlToUrlCalls.count, 0)
    }
    
    func testPlaceTransfer_parentDirectoryIsFile_errorReturned() throws {
        let (sut, _, fileSystemMock) = createSut(
            directoryState: .exists(isDirectory: false),
            hasFileMoveError: true
        )
        
        XCTAssertThrowsError(
            try sut.placeTransfer(Copy.testTransfer, from: Copy.tempFileUrl)
        ) { error in
            XCTAssertEqual(error as? BucketRepositoryError, .parentIsFile)
        }
        XCTAssertEqual(fileSystemMock.moveFileAtUrlToUrlCalls.count, 0)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        directoryState: HostDirectoryState,
        hasFileMoveError: Bool
    ) -> (
        FileTransferPlacerImpl,
        LocalUrlFinderMock,
        FileSystemMock
    ) {
        let localUrlFinderMock = LocalUrlFinderMock()
        localUrlFinderMock.localUrlForRelativeFilePathAndBucketNameResult = Copy.targetFileUrl
        
        let fileSystemMock = FileSystemMock()
        fileSystemMock.fileExistsAtPathIsDirectoryResult = { isDirectoryRef in
            switch directoryState {
            case .exists(let isDirectory):
                isDirectoryRef.pointee = ObjCBool(isDirectory)
                return true
            case .notExists:
                return false
            }
        }
        
        if case .notExists(let hasCreateError) = directoryState {
            if hasCreateError {
                fileSystemMock.createDirectoryAtPathWithIntermeidateDirectoriesError = Copy.createDirectoryError
            }
        }
        
        if hasFileMoveError {
            fileSystemMock.moveFileAtUrlToUrlError = Copy.moveFileError
        }
        
        let sut = FileTransferPlacerImpl(
            localUrlFinder: localUrlFinderMock,
            fileSystem: fileSystemMock
        )
        
        return (
            sut,
            localUrlFinderMock,
            fileSystemMock
        )
    }
    
    private enum HostDirectoryState {
        case exists(isDirectory: Bool)
        case notExists(hasCreateError: Bool)
    }
    
    private enum Copy {
        static let relativePath = "folder1/filename.ext"
        static let bucketName = "some-test-bucket"
        static let testTransfer = Transfer(
            relativeFilePath: relativePath,
            bucketName: bucketName,
            taskIdentifier: 12
        )
        
        static let tempFilePath = "/tmp/tmp_123"
        static let tempFileUrl = URL(fileURLWithPath: tempFilePath)
        
        static let targetFilePath = "/documents/bucket-a/folder1/filename.ext"
        static let targetFileUrl = URL(fileURLWithPath: targetFilePath)
        
        static let createDirectoryError = NSError(domain: "createDirError", code: 1)
        static let moveFileError = NSError(domain: "moveFileError", code: 2)
    }
}
