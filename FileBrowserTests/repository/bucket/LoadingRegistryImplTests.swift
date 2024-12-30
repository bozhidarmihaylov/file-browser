//
//  LoadingRegistryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class LoadingRegistryImplTests: XCTestCase {

    // MARK: registerTransfer()
    
    func testRegisterTransfer_success_statesLoaded() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()

        let setBefore = sut.downloadsInProgress
        try await sut.registerTransfer(Copy.updateTransfer)
        let setAfter = sut.downloadsInProgress

        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
        XCTAssertFalse(setBefore.count != 0)
        XCTAssertTrue(setAfter.count != 0)
    }
    
    func testRegisterTransfer_doneTwice_statesLoadedOnce() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()

        try await sut.registerTransfer(Copy.updateTransfer)
        try await sut.registerTransfer(Copy.updateTransfer)
        
        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
    }
    
    func testRegisterTransfer_success_addedOrUpdated() async throws {
        for isTransferIn in [false, true] {
            let (sut, _, _, transferDaoMock, _) = createSut(
                isTransferIn: isTransferIn
            )
            
            try await sut.registerTransfer(Copy.updateTransfer)
            
            XCTAssertEqual(transferDaoMock.insertOrUpdateTransferCalls.count, 1)
            XCTAssertEqual(transferDaoMock.insertOrUpdateTransferCalls.last, Copy.updateTransfer)
            XCTAssertTrue(sut.downloadsInProgress.contains(Copy.fullPath))
        }
    }
    
    func testRegisterTransfer_loadingStatesError_errorReturned() async throws {
        
        let (sut, _, _, transferDaoMock, _) = createSut(
            isTransferIn: false,
            hasLoadingStatesError: true
        )

        await assertThrowsAsyncError(
            try await sut.registerTransfer(Copy.updateTransfer)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.loadingStatesError)
        }
        
        XCTAssertEqual(transferDaoMock.insertOrUpdateTransferCalls.count, 0)
        XCTAssertFalse(sut.downloadsInProgress.contains(Copy.fullPath))
    }

    func testRegisterTransfer_insertOrUpdateError_errorReturned() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut(
            isTransferIn: false,
            hasInsertOrUpdateError: true
        )

        await assertThrowsAsyncError(
            try await sut.registerTransfer(Copy.updateTransfer)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.insertOrUpdateError)
        }
        
        XCTAssertEqual(transferDaoMock.insertOrUpdateTransferCalls.count, 1)
        XCTAssertEqual(transferDaoMock.insertOrUpdateTransferCalls.last, Copy.updateTransfer)
        XCTAssertTrue(sut.downloadsInProgress.contains(Copy.fullPath))
    }
    
    
    // MARK: unregisterTransfer()
    
    func testUnregisterTransfer_success_statesLoaded() async throws {
        for byTaskId in [false, true] {
            let (sut, _, _, transferDaoMock, _) = createSut()
            
            let setBefore = sut.downloadsInProgress
            try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
            let setAfter = sut.downloadsInProgress
            
            XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
            XCTAssertFalse(setBefore.count != 0)
            XCTAssertTrue(setAfter.count != 0)
        }
    }
    
    func testUnregisterTransfer_doneTwice_statesLoadedOnce() async throws {
        for byTaskId in [false, true] {
            let (sut, _, _, transferDaoMock, _) = createSut()
            
            try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
            try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
            
            XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
        }
    }
    
    func testUnregisterTransfer_success_removed() async throws {
        for byTaskId in [false, true] {
            for isTransferIn in [false, true] {
                let (sut, _, _, transferDaoMock, _) = createSut(
                    isTransferIn: isTransferIn
                )
                
                try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
                
                guard !byTaskId || isTransferIn else {
                    return
                }
                
                XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.count, 1)
                XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.last?.path, Copy.transfer.relativeFilePath)
                XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.last?.bucketName, Copy.transfer.bucketName)
            }
        }
    }
    
    func testUnregisterTransfer_loadingStatesError_errorReturned() async throws {
        for byTaskId in [false, true] {
            let (sut, _, _, transferDaoMock, _) = createSut(
                hasLoadingStatesError: true
            )
            
            await assertThrowsAsyncError(
                try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
            ) { error in
                XCTAssertEqual(error as NSError, Copy.loadingStatesError)
            }
            
            XCTAssertEqual(transferDaoMock.deleteByTaskIdCalls.count, 0)
        }
    }

    func testUnregisterTransfer_deleteError_errorReturned() async throws {
        for byTaskId in [false, true] {
            let (sut, _, _, transferDaoMock, _) = createSut(
                hasDeleteTransferError: true
            )
            
            await assertThrowsAsyncError(
                try await unregisterTransfer(sut: sut, isByTaskId: byTaskId)
            ) { error in
                XCTAssertEqual(error as NSError, Copy.deleteTransferError)
            }
            
            XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.count, 1)
            XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.last?.path, Copy.updateTransfer.relativeFilePath)
            XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.last?.bucketName, Copy.updateTransfer.bucketName)
            XCTAssertFalse(sut.downloadsInProgress.contains(Copy.fullPath))
        }
    }
    
    func testUnregisterTransfer_findByTaskIdError_errorReturned() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut(
            hasFindByTaskIdError: true
        )
        
        await assertThrowsAsyncError(
            try await unregisterTransfer(sut: sut, isByTaskId: true)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.findByTaskIdError)
        }
        
        XCTAssertEqual(transferDaoMock.deleteByPathAndBucketNameCalls.count, 0)
    }
    
    // MARK: downloadingState(for:, in:)
    
    func testDownloadingState_success_statesLoaded() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()
        
        let setBefore = sut.downloadsInProgress
        _ = try await downloadingState(sut: sut)
        let setAfter = sut.downloadsInProgress
        
        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
        XCTAssertFalse(setBefore.count != 0)
        XCTAssertTrue(setAfter.count != 0)    }
    
    func testDownloadingState_doneTwice_statesLoadedOnce() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()
        
        _ = try await downloadingState(sut: sut)
        _ = try await downloadingState(sut: sut)
        
        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
    }
    
    func testDownloadingState_isLoading_loadingReturned() async throws {
        let (sut, _, _, _, _) = createSut()
        
        let loadingState = try await downloadingState(sut: sut)
        
        XCTAssertEqual(loadingState, .loading)
    }
    
    func testDownloadingState_notLoadingAndFileExists_loadedReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            isTransferIn: false,
            fileExistsAtPath: true
        )
        
        let loadingState = try await downloadingState(sut: sut)
        
        XCTAssertEqual(loadingState, .loaded)
    }
    
    func testDownloadingState_notLoadingAndFileDoesNotExists_notLoadedReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            isTransferIn: false,
            fileExistsAtPath: false
        )
        
        let loadingState = try await downloadingState(sut: sut)
        
        XCTAssertEqual(loadingState, .notLoaded)
    }
    
    func testDownloadingState_loadingStatesError_errorReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            hasLoadingStatesError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadingState(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.loadingStatesError)
        }
    }
    
    // MARK: downloadingStates(for:, in:)
    
    func testDownloadingStates_success_statesLoaded() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()
        
        let setBefore = sut.downloadsInProgress
        _ = try await downloadingStates(sut: sut)
        let setAfter = sut.downloadsInProgress
        
        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
        XCTAssertFalse(setBefore.count != 0)
        XCTAssertTrue(setAfter.count != 0)    }
    
    func testDownloadingStates_doneTwice_statesLoadedOnce() async throws {
        let (sut, _, _, transferDaoMock, _) = createSut()
        
        _ = try await downloadingStates(sut: sut)
        _ = try await downloadingStates(sut: sut)
        
        XCTAssertEqual(transferDaoMock.getAllCallsCount, 1)
    }
    
    func testDownloadingStates_called_statesRetrieved() async throws {
        let (sut, fileSystemMock, _, transferDaoMock, _) = createSut()
        
        fileSystemMock.fileExistsAtPathClosure = {
            $0 == Copy.fullPath
        }
        
        transferDaoMock.getAllResult = [Copy.allTransfers.last!]
                        
        let loadingStates = try await downloadingStates(sut: sut)
        
        XCTAssertEqual(loadingStates, [.notLoaded, .loaded, .loading])
    }

    func testDownloadingStates_loadingStatesError_errorReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            hasLoadingStatesError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadingStates(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.loadingStatesError)
        }
    }
        
    // MARK: Helper methods

    private func createSut(
        haveTransfers: Bool = true,
        isTransferIn: Bool = true,
        fileExistsAtPath: Bool = false,
        hasLoadingStatesError: Bool = false,
        hasInsertOrUpdateError: Bool = false,
        hasDeleteTransferError: Bool = false,
        hasFindByTaskIdError: Bool = false
    ) -> (
        LoadingRegistryImpl,
        FileSystemMock,
        AsyncPerformerMock,
        TransferDaoMock,
        LocalUrlFinderMock
    ) {
        let fileSystemMock = FileSystemMock()
        fileSystemMock.fileExistsAtPathClosure = { fullPath in
            fileExistsAtPath && fullPath == Copy.fullPath
        }
        
        let asyncPerformerMock = AsyncPerformerMock()
        
        let transferDaoMock = TransferDaoMock()
        if hasLoadingStatesError {
            transferDaoMock.getAllError = Copy.loadingStatesError
        } else if !haveTransfers {
            transferDaoMock.getAllResult = []
        } else if isTransferIn && !fileExistsAtPath {
            transferDaoMock.getAllResult = Copy.allTransfers
        } else {
            transferDaoMock.getAllResult = Copy.allTransfersButOurs
        }
        
        if hasFindByTaskIdError {
            transferDaoMock.getByTaskIdError = Copy.findByTaskIdError
        } else if haveTransfers && isTransferIn {
            transferDaoMock.getByTaskIdResult = Copy.transfer
        }

        if hasInsertOrUpdateError {
            transferDaoMock.insertOrUpdateTransferError = Copy.insertOrUpdateError
        }
        
        if hasDeleteTransferError {
            transferDaoMock.deleteByPathAndBucketNameError = Copy.deleteTransferError
        } else {
            transferDaoMock.deleteByPathAndBucketNameResult = Copy.transfer
        }
        
        let localUrlFinderMock = LocalUrlFinderMock()
        localUrlFinderMock.localUrlForRelativeFilePathAndBucketNameClosure = { relativeFilePath, bucketName in
            URL(fileURLWithPath: "/documents/\(bucketName)/\(relativeFilePath)")
        }
        
        let sut = LoadingRegistryImpl(
            fileSystem: fileSystemMock,
            asyncPerformer: asyncPerformerMock,
            transferDao: transferDaoMock,
            localUrlFinder: localUrlFinderMock
        )
        return (
            sut,
            fileSystemMock,
            asyncPerformerMock,
            transferDaoMock,
            localUrlFinderMock
        )
    }
    
    private func unregisterTransfer(
        sut: LoadingRegistry,
        isByTaskId: Bool
    ) async throws {
        if isByTaskId {
            try await sut.unregisterTransfer(taskId: Copy.taskId)
        } else {
            try await sut.unregisterTransfer(Copy.transfer)
        }
    }
    
    private func downloadingState(
        sut: LoadingRegistry
    ) async throws -> LoadingState {
        try await sut.downloadingState(
            for: Copy.path,
            in: Copy.bucketName
        )
    }
    
    private func downloadingStates(
        sut: LoadingRegistry
    ) async throws -> [LoadingState] {
        try await sut.downloadingStates(
            for: Copy.allPaths,
            in: Copy.bucketName
        )
    }
    
    private enum Copy {
        static let loadingStatesError = NSError(domain: "loadingStatesError", code: 1)
        static let insertOrUpdateError = NSError(domain: "insertOrUpdateError", code: 2)
        static let deleteTransferError = NSError(domain: "deleteTransferError", code: 3)
        static let findByTaskIdError = NSError(domain: "findByTaskIdError", code: 4)
        
        static let bucketName = "some-bucket-name"
        
        static let taskId = 3
        static let path = "folder1/f2.ext2"
        static let fullPath = "/documents/\(bucketName)/\(path)"
        static let url = URL(fileURLWithPath: fullPath)
        
        static let transfer = Transfer(
            relativeFilePath: path,
            bucketName: bucketName,
            taskIdentifier: taskId
        )
        
        static let updateTaskId = 5
        static let updateTransfer = transfer.copy(
            taskIdentifier: updateTaskId
        )
        static let allTransfers = [
            Transfer(
                relativeFilePath: "folder1/f1.ext1",
                bucketName: bucketName,
                taskIdentifier: 1
            ),
            transfer,
            Transfer(
                relativeFilePath: "folder1/f3.ext3",
                bucketName: bucketName,
                taskIdentifier: 7
            )
        ]
        
        static let allTransfersButOurs = allTransfers
            .filter { $0.taskIdentifier != taskId }
        
        static let allPaths = allTransfers.map(\.relativeFilePath)
    }
}
