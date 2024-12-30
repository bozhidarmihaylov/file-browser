//
//  ApiBucketRepositoryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class ApiBucketRepositoryImplTests: XCTestCase {
    // MARK: getContent(path:)
    
    func testGetContent_called_dependenciesSet() {
        let (
            sut,
            apiConfigStoreMock,
            folderContentLoaderMock,
            _,
            createEntryPageSequenceSpy,
            createAnyAsyncSequenceSpy
        ) = createSut()
        
        let result = sut.getContent(path: Copy.path)
        
        XCTAssertEqual(createEntryPageSequenceSpy.path, Copy.path)
        XCTAssertEqual(createEntryPageSequenceSpy.pageSize, Copy.pageSize)
        XCTAssertIdentical(createEntryPageSequenceSpy.apiConfigProvider as? AnyObject, apiConfigStoreMock)
        XCTAssertIdentical(createEntryPageSequenceSpy.folderContentLoader as? AnyObject, folderContentLoaderMock)
        
        XCTAssertIdentical(createAnyAsyncSequenceSpy.underlying, createEntryPageSequenceSpy.resultSequence)
        
        XCTAssertIdentical(createAnyAsyncSequenceSpy.underlying, createEntryPageSequenceSpy.resultSequence)
        
        XCTAssertEqual(createAnyAsyncSequenceSpy.resultSequence.id, result.id)
    }
    
    // MARK: downloadFile(path:)
    
    func testDownloadFile_success_configFetchedFromProvider() async throws {
        let (sut, apiConfigStoreMock, _, _, _, _) = createSut()
        
        _ = try await sut.downloadFile(path: Copy.path)
        
        XCTAssertEqual(apiConfigStoreMock.configGetCallsCount, 1)
    }
    
    func testDownloadFile_noConfig_errorReturned() async throws {
        let (sut, apiConfigStoreMock, _, _, _, _) = createSut(
            hasConfig: false
        )
        
        await assertThrowsAsyncError(
            try await sut.downloadFile(path: Copy.path)
        ) { error in
            XCTAssertEqual(error as? BucketRepositoryError, .noConfig)
        }
        
        XCTAssertEqual(apiConfigStoreMock.configGetCallsCount, 1)
    }
    
    func testDownloadFile_downloadError_errorReturned() async throws {
        let (sut, apiConfigStoreMock, _, _, _, _) = createSut(
            hasDownloadFileError: true
        )
        
        await assertThrowsAsyncError(
            try await sut.downloadFile(path: Copy.path)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.downloadFileError)
        }
        
        XCTAssertEqual(apiConfigStoreMock.configGetCallsCount, 1)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasConfig: Bool = true,
        hasDownloadFileError: Bool = false
    ) -> (
        ApiBucketRepositoryImpl,
        ApiConfigStoreMock,
        FolderContentLoaderMock,
        FileDownloaderMock,
        CreateEntryPageSequenceSpy,
        CreateAnyAsyncSequenceSpy
    ) {
        let apiConfigStoreMock = ApiConfigStoreMock()
        if hasConfig {
            apiConfigStoreMock._config = Copy.config
        }
        
        let folderContentLoaderMock = FolderContentLoaderMock()

        let fileDownloaderMock = FileDownloaderMock()
        if hasDownloadFileError {
            fileDownloaderMock.downloadFileError = Copy.downloadFileError
        } else {
            fileDownloaderMock.downloadFileResult = Copy.downloadResult
        }
        
        let createEntryPageSequenceSpy = CreateEntryPageSequenceSpy()
        let createAnyAsyncSequenceSpy = CreateAnyAsyncSequenceSpy()
        
        let sut = ApiBucketRepositoryImpl(
            apiConfigProvider: apiConfigStoreMock,
            folderContentLoader: folderContentLoaderMock,
            fileDownloader: fileDownloaderMock,
            apiEntryPageSequenceFactory: {
                let resultSequence = BlankAsyncSequence<[Entry]>()
                createEntryPageSequenceSpy.path = $0
                createEntryPageSequenceSpy.pageSize = $1
                createEntryPageSequenceSpy.apiConfigProvider = $2
                createEntryPageSequenceSpy.folderContentLoader = $3
                createEntryPageSequenceSpy.resultSequence = resultSequence
                return resultSequence
            },
            anyAsyncSequenceFactory: {
                var underlying = $0
                let resultSequnce = AnyAsyncSequence(sequence: &underlying)
                
                createAnyAsyncSequenceSpy.underlying = underlying
                createAnyAsyncSequenceSpy.resultSequence = resultSequnce
                
                return resultSequnce
            }
        )
        
        return (
            sut,
            apiConfigStoreMock,
            folderContentLoaderMock,
            fileDownloaderMock,
            createEntryPageSequenceSpy,
            createAnyAsyncSequenceSpy
        )
    }
    
    private enum Copy {
        static let path = "folder1/file.ext"
        static let pageSize = 20
        static let config = ApiConfig.mock
        
        static let downloadResult = Entry(
            name: "file.ext",
            path: path,
            bucketName: config.bucket.name,
            isFolder: false,
            loadingState: .loaded
        )
        static let downloadFileError = NSError(domain: "downloadFileError", code: 1)
    }
    
    private final class CreateEntryPageSequenceSpy {
        var path: String! = nil
        var pageSize: Int! = nil
        var apiConfigProvider: ApiConfigProvider! = nil
        var folderContentLoader: FolderContentLoader! = nil
        var resultSequence: BlankAsyncSequence<[Entry]>! = nil
    }
    
    private final class CreateAnyAsyncSequenceSpy {
        var underlying: BlankAsyncSequence<[Entry]>! = nil
        var resultSequence: AnyAsyncSequence<[Entry]>! = nil
    }
}
