//
//  FileDownloaderImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileDownloaderImplTest: XCTestCase {
    
    // MARK: init()
    
    func testInit_called_httpTransferDelegateSetToSut() async throws {
        let (sut, _, _, httpTransferClientMock, _ , _, _, _, _, _) = createSut()
        
        XCTAssertIdentical(httpTransferClientMock.transferDelegate, sut)
    }

    // MARK: downloadFile()
    
    func testDownloadFile_success_loadedFileEntryReturned() async throws {
        let (sut, _, _, _, _, _, _, _, _, _) = createSut()
        
        let entry = try await downloadFile(sut: sut)

        XCTAssertEqual(Copy.downloadExpectedResult, entry)
    }
    
    func testDownloadFile_success_paramsSentToRequestFactory() async throws {
        let (sut, requestFactoryMock, _, _, _, _, _, _, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(requestFactoryMock.createDownloadRequestCalls.count, 1)
        XCTAssertEqual(requestFactoryMock.createDownloadRequestCalls.last?.filePath, Copy.path)
        XCTAssertEqual(requestFactoryMock.createDownloadRequestCalls.last?.config, Copy.config)
    }
    
    func testDownloadFile_success_requestSentToTransferClient() async throws {
        let (sut, _, _, httpTransferClientMock, _, _, _, _, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(httpTransferClientMock.downloadFileForRequestCalls.count, 1)
        XCTAssertEqual(httpTransferClientMock.downloadFileForRequestCalls.last, Copy.request)
    }
    
    func testDownloadFile_success_pendingTransferRegistered() async throws {
        let (sut, _, _, _, registryMock, _, _, _, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
    }
    
    func testDownloadFile_success_taskResumed() async throws {
        let (sut, _, transferTaskMock, _, _, _, _, _, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(transferTaskMock.resumeCallCount, 1)
    }
    
    func testDownloadFile_success_initialFileMovedToTemporaryLocation() async throws {
        let (sut, _, _, _, _, _, _, _, fileSystemMock, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(fileSystemMock.moveFileAtUrlToUrlCalls.count, 1)
        XCTAssertEqual(fileSystemMock.moveFileAtUrlToUrlCalls.last?.atUrl, Copy.temporaryFileUrl)
        XCTAssertEqual(fileSystemMock.moveFileAtUrlToUrlCalls.last?.toUrl, Copy.saveTemporaryFileUrl)
    }
    
    func testDownloadFile_success_filePlacedFromSaveTemporaryUrl() async throws {
        let (sut, _, _, _, _, _, _, transferPlacerMock, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(transferPlacerMock.placeTransferCalls.count, 1)
        XCTAssertEqual(transferPlacerMock.placeTransferCalls.last?.transfer, Copy.transferExpectedResult)
        XCTAssertEqual(transferPlacerMock.placeTransferCalls.last?.temporaryUrl, Copy.saveTemporaryFileUrl)
    }
    
    func testDownloadFile_success_transferUnregistered() async throws {
        let (sut, _, _, _, registryMock, _, _, _, _, _) = createSut()
        
        _ = try await downloadFile(sut: sut)

        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferCalls.last, Copy.transferExpectedResult)
    }
    
    func testDownloadFile_registerError_errorReturned() async throws {
        let (sut, _, transferTaskMock, _, registryMock, _, _, _, _, _) = createSut(
            hasRegisterTransferError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadFile(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.registerTransferError)
        }
        
        XCTAssertEqual(transferTaskMock.resumeCallCount, 0)
        
        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 0)
    }
    
    func testDownloadFile_httpTransferError_errorReturned() async throws {
        let (sut, _, transferTaskMock, _, registryMock, _, _, _, _, _) = createSut(
            hasHttpError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadFile(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.httpTransferError)
        }
        
        XCTAssertEqual(transferTaskMock.resumeCallCount, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferCalls.last, Copy.transferExpectedResult)
    }
    
    func testDownloadFile_hasInitialFileMoveError_errorReturned() async throws {
        let (sut, _, transferTaskMock, _, registryMock, _, _, _, _, _) = createSut(
            hasInitialFileMoveError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadFile(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.hasInitialFileMoveError)
        }
        
        XCTAssertEqual(transferTaskMock.resumeCallCount, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferCalls.last, Copy.transferExpectedResult)
    }
    
    func testDownloadFile_filePlacingError_errorReturned() async throws {
        let (sut, _, transferTaskMock, _, registryMock, _, _, filePlacerMock, _, _) = createSut(
            hasFilePlacingError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadFile(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.filePlacingError)
        }
        
        XCTAssertEqual(transferTaskMock.resumeCallCount, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(filePlacerMock.placeTransferCalls.count, 1)
        XCTAssertEqual(filePlacerMock.placeTransferCalls.last?.transfer, Copy.transferExpectedResult)
        XCTAssertEqual(filePlacerMock.placeTransferCalls.last?.temporaryUrl, Copy.saveTemporaryFileUrl)
    }
    
    func testDownloadFile_unregisterTransferError_errorReturned() async throws {
        let (sut, _, transferTaskMock, _, registryMock, _, _, filePlacerMock, _, _) = createSut(
            hasUnregisterTransferError: true
        )
        
        await assertThrowsAsyncError(
            try await downloadFile(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.unregisterTransferError)
        }
        
        XCTAssertEqual(transferTaskMock.resumeCallCount, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 1)
        XCTAssertEqual(registryMock.registerTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(registryMock.unregisterTransferCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferCalls.last, Copy.transferExpectedResult)
        
        XCTAssertEqual(filePlacerMock.placeTransferCalls.count, 1)
        XCTAssertEqual(filePlacerMock.placeTransferCalls.last?.transfer, Copy.transferExpectedResult)
        XCTAssertEqual(filePlacerMock.placeTransferCalls.last?.temporaryUrl, Copy.saveTemporaryFileUrl)
    }
    
    // MARK: didFailDownloading()
    
    func testDidFailDownloading_noStoredContinuation_unregistersTheTransfer() async throws {
        let (sut, _, _, _, registryMock, _, _, _, _, taskLauncherMock) = createSut()
        
        sut.didFailDownloading(
            taskId: Copy.taskIdentifier,
            with: Copy.httpTransferError
        )
        
        let task = taskLauncherMock.launchTasks.last
        _ = try await task?.value
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 0)
        
        XCTAssertEqual(registryMock.unregisterTransferByTaskIdCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferByTaskIdCalls.last, Copy.taskIdentifier)
    }
    
    // MARK: didFinishDownloading()
    
    func testDidFinishDownloading_noStoredContinuation_placesAndUnregistersTheTransfer() async throws {
        try await verifyDidFinishDownloading()
    }
    
    func testDidFinishDownloading_noStoredContinuationAndTransferLookupError_noErrorThrown() async throws {
        try await verifyDidFinishDownloading(
            hasTransferByTaskIdLookupError: true
        )
    }
    
    func testDidFinishDownloading_noStoredContinuationAndUnregisterFails_noErrorThrown() async throws {
        try await verifyDidFinishDownloading(
            hasUnregisterTransferError: true
        )
    }
    
    func testDidFinishDownloading_noStoredContinuationAndPlaceTransferFails_noErrorThrown() async throws {
        try await verifyDidFinishDownloading(
            hasFilePlacingError: true
        )
    }
    
    func testDidFinishDownloading_noStoredContinuationAndInitialFileMoveFails_noErrorThrown() async throws {
        try await verifyDidFinishDownloading(
            hasInitialFileMoveError: true
        )
    }
    
    // MARK: didRecreateDownloadSession()
    
    func testDidRecreateDownloadSession_called_transfersWithTasksNotInSentOnesAreDeleted() async throws {
        let (sut, _, _, _, _, transferDaoMock, _, _, _, taskLauncherMock) = createSut()
        
        sut.didRecreateBackgroundSession(with: Copy.downloadTasks)
        
        let task = taskLauncherMock.launchTasks.last
        _ = try await task?.value
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        
        XCTAssertEqual(transferDaoMock.deleteTransfersWithTaskIdsNotInTaskIdsCalls.count, 1)
        XCTAssertEqual(transferDaoMock.deleteTransfersWithTaskIdsNotInTaskIdsCalls.last, Copy.downloadTaskIds)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasRegisterTransferError: Bool = false,
        hasHttpError: Bool = false,
        hasInitialFileMoveError: Bool = false,
        hasFilePlacingError: Bool = false,
        hasUnregisterTransferError: Bool = false,
        hasTransferByTaskIdLookupError: Bool = false
    ) -> (
        FileDownloaderImpl,
        FileDownloadRequestFactoryMock,
        HttpTaskMock,
        HttpTransferClientMock,
        LoadingRegistryMock,
        TransferDaoMock,
        SyncPerformerMock,
        FileTransferPlacerMock,
        FileSystemMock,
        TaskLauncherMock
    ) {
        let requestFactoryMock = FileDownloadRequestFactoryMock()
        requestFactoryMock.createDownloadRequestResult = Copy.request
        
        let httpTaskMock = HttpTaskMock()
        httpTaskMock.identifier = Copy.taskIdentifier
        httpTaskMock.currentRequest = Copy.request
        httpTaskMock.progress = Copy.progres

        let httpTransferClientMock = HttpTransferClientMock()
        httpTransferClientMock.downloadFileForRequestResult = httpTaskMock
        
        let loadingRegistryMock = LoadingRegistryMock()
        if hasRegisterTransferError {
            loadingRegistryMock.registerTransferError = Copy.registerTransferError
        }
        if hasUnregisterTransferError {
            loadingRegistryMock.unregisterTransferError = Copy.unregisterTransferError
        }
        
        let transferDaoMock = TransferDaoMock()
        if hasTransferByTaskIdLookupError {
            transferDaoMock.getByTaskIdError = Copy.transferByTaskIdLookupError
        } else {
            transferDaoMock.getByTaskIdResult = Copy.transferExpectedResult
        }
        
        let syncPerformerMock = SyncPerformerMock()
        
        let fileTransferPlacerMock = FileTransferPlacerMock()
        if hasFilePlacingError {
            fileTransferPlacerMock.placeTransferError = Copy.filePlacingError
        }
        
        let fileSystemMock = FileSystemMock()
        fileSystemMock.temporaryDirectoryUrlResult = Copy.temporaryDirectoryUrl
        if hasInitialFileMoveError {
            fileSystemMock.moveFileAtUrlToUrlError = Copy.hasInitialFileMoveError
        }
        
        let taskLauncherMock = TaskLauncherMock()
        
        let currentProviderDateMock = CurrentDateProviderMock()
        currentProviderDateMock.currentDateResult = Copy.date
        
        let sut = FileDownloaderImpl(
            requestFactory: requestFactoryMock,
            httpTransferClient: httpTransferClientMock,
            loadingRegistry: loadingRegistryMock,
            transferDao: transferDaoMock,
            syncPerformer: syncPerformerMock,
            fileTransferPlacer: fileTransferPlacerMock,
            fileSystem: fileSystemMock,
            taskLauncher: taskLauncherMock,
            currentDateProvider: currentProviderDateMock
        )
        
        httpTaskMock.resumeOnCall = {
            if hasHttpError {
                sut.didFailDownloading(
                    taskId: Copy.taskIdentifier,
                    with: Copy.httpTransferError
                )
            } else {
                sut.didFinishDownloading(
                    taskId: Copy.taskIdentifier,
                    to: Copy.temporaryFileUrl
                )
            }
        }
        
        return (
            sut,
            requestFactoryMock,
            httpTaskMock,
            httpTransferClientMock,
            loadingRegistryMock,
            transferDaoMock,
            syncPerformerMock,
            fileTransferPlacerMock,
            fileSystemMock,
            taskLauncherMock
        )
    }
    
    private func downloadFile(sut: FileDownloader) async throws -> Entry {
        try await sut.downloadFile(
            path: Copy.path, 
            config: Copy.config
        )
    }
    
    private func verifyDidFinishDownloading(
        hasInitialFileMoveError: Bool = false,
        hasFilePlacingError: Bool = false,
        hasUnregisterTransferError: Bool = false,
        hasTransferByTaskIdLookupError: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        let (sut, _, _, _, registryMock, transferDaoMock, _, transferPlacerMock, _, taskLauncherMock) = createSut(
            hasInitialFileMoveError: hasInitialFileMoveError,
            hasFilePlacingError: hasFilePlacingError,
            hasUnregisterTransferError: hasUnregisterTransferError,
            hasTransferByTaskIdLookupError: hasTransferByTaskIdLookupError
        )
        
        sut.didFinishDownloading(
            taskId: Copy.taskIdentifier,
            to: Copy.temporaryFileUrl
        )
        
        let task = taskLauncherMock.launchTasks.last
        
        do {
            _ = try await task?.value
        } catch {
            XCTFail("Unexpected error thrown \(error)")
        }
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)

        XCTAssertEqual(registryMock.registerTransferCalls.count, 0)

        XCTAssertEqual(registryMock.unregisterTransferByTaskIdCalls.count, 1)
        XCTAssertEqual(registryMock.unregisterTransferByTaskIdCalls.last, Copy.taskIdentifier)
        
        guard !hasInitialFileMoveError else {
            XCTAssertEqual(transferDaoMock.getByTaskIdCalls.count, 0)
            XCTAssertEqual(transferPlacerMock.placeTransferCalls.count, 0)
            return
        }
        
        XCTAssertEqual(transferDaoMock.getByTaskIdCalls.count, 1)
        XCTAssertEqual(transferDaoMock.getByTaskIdCalls.last, Copy.taskIdentifier)
        
        guard !hasTransferByTaskIdLookupError else {
            XCTAssertEqual(transferPlacerMock.placeTransferCalls.count, 0)
            return
        }
        
        XCTAssertEqual(transferPlacerMock.placeTransferCalls.count, 1)
        XCTAssertEqual(transferPlacerMock.placeTransferCalls.last?.transfer, Copy.transferExpectedResult)
        XCTAssertEqual(transferPlacerMock.placeTransferCalls.last?.temporaryUrl, Copy.saveTemporaryFileUrl)
    }
    
    private enum Copy {
        static let path = "folder1/file.ext"
        
        static let downloadExpectedResult = Entry(
            name: "file.ext",
            path: path,
            bucketName: config.bucket.name,
            isFolder: false,
            loadingState: .loaded
        )
        
        static let transferExpectedResult = Transfer(
            relativeFilePath: Copy.path,
            bucketName: config.bucket.name,
            taskIdentifier: Copy.taskIdentifier
        )
        
        static let registerTransferError = NSError(domain: "registerTransferError", code: 1)
        static let httpTransferError = NSError(domain: "httpTransferError", code: 2)
        static let hasInitialFileMoveError = NSError(domain: "hasInitialFileMoveError", code: 3)
        static let unregisterTransferError = NSError(domain: "unregisterTransferError", code: 4)
        static let filePlacingError = NSError(domain: "filePlacingError", code: 5)
        
        static let transferByTaskIdLookupError = NSError(domain: "transferByTaskIdLookupError", code: 6)
        
        static let taskIdentifier = 11
        static let request = URLRequest(url: URL(string: "http://some.host/some-path")!)
        static let progres = Progress()
        
        static let config = ApiConfig.mock
        
        static let date = Date.mock
        
        static let temporaryDirectoryUrl = URL(fileURLWithPath: "/tmp")
        static let temporaryFileUrl = URL(fileURLWithPath: "/tmp/tmp_32421")
        static let saveTemporaryFileUrl = URL(fileURLWithPath: "/tmp/download_task_#11_\(date.timeIntervalSince1970)")
        
        static let downloadTaskIds = [11, 13, 29]
        static let downloadTasks = downloadTaskIds
            .map(HttpTaskMock.init)
    }
}
