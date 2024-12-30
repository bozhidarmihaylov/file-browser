//
//  ApiEntryPageSequenceTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class ApiEntryPageSequenceTests: XCTestCase {
    func testIteratorNext_noConfig_nilReturned() async throws {
        let (sut, _, contentLoaderMock) = createSut(
            hasConfig: false
        )

        let result = try await sut.next()
        
        XCTAssertNil(result)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.count, 0)
    }
    
    func testIteratorNext_gotEmptyFolderContent_singleEmptyPageReturned() async throws {
        let (sut, _, _) = createSut(
            hasEntries: false
        )
        
        let result = try await sut.next()
        let nextResult = try await sut.next()
        
        XCTAssertEqual(result, [])
        XCTAssertNil(nextResult)
    }
    
    func testIteratorNext_gotNoContinuationPageFolderContent_singlePageReturned() async throws {
        let (sut, _, _) = createSut()
        
        let result = try await sut.next()
        let nextResult = try await sut.next()
        
        XCTAssertEqual(result, Copy.pageEntries)
        XCTAssertNil(nextResult)
    }
    
    func testIteratorNext_gotPageWithContinuationFolderContent_multiplePagesReturned() async throws {
        let (sut, _, _) = createSut(
            hasNextPage: true
        )
        
        let result = try await sut.next()
        let nextResult = try await sut.next()
        
        XCTAssertEqual(result, Copy.pageEntries)
        XCTAssertEqual(nextResult, Copy.pageEntries)
    }
    
    func testIteratorNext_called_configFetchedOnce() async throws {
        let (sut, configProviderMock, _) = createSut()
        
        _ = try await sut.next()
        
        XCTAssertEqual(configProviderMock.configGetCallsCount, 1)
    }
    
    func testIteratorNext_gotNoContinuationPageFolderContent_folderContentFetchedOnce() async throws {
        let (sut, _, contentLoaderMock) = createSut()
        
        _ = try await sut.next()
        _ = try await sut.next()
        
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.count, 1)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.path, Copy.path)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.continuationToken, nil)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.pageSize, Copy.pageSize)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.config, Copy.config)
    }
    
    func testIteratorNext_gotPageWithContinuationFolderContent_folderContentFetchedOnce() async throws {
        let (sut, _, contentLoaderMock) = createSut(
            hasNextPage: true
        )
        
        _ = try await sut.next()
        _ = try await sut.next()
        
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.count, 2)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.path, Copy.path)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.continuationToken, Copy.pageContinuationToken)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.pageSize, Copy.pageSize)
        XCTAssertEqual(contentLoaderMock.getContentWithPathContinuationTokenPageSizeConfigCalls.last?.config, Copy.config)
    }
    
    func testIteratorNext_fetchPageError_errorThrown() async throws {
        let (sut, _, _) = createSut(
            fetchError: true
        )
        
        await assertThrowsAsyncError(
            try await sut.next()
        ) { error in
            XCTAssertEqual(error as NSError, Copy.testError)
        }
        
        await assertThrowsAsyncError(
            try await sut.next()
        ) { error in
            XCTAssertEqual(error as NSError, Copy.testError)
        }
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasConfig: Bool = true,
        hasEntries: Bool = true,
        hasNextPage: Bool = false,
        fetchError: Bool = false
    ) -> (
        ApiEntryPageSequence.PageIterator,
        ApiConfigStoreMock,
        FolderContentLoaderMock
    ) {
        let apiConfigProviderMock = ApiConfigStoreMock()
        apiConfigProviderMock.config = hasConfig ? Copy.config : nil
        
        let folderContentLoaderMock = FolderContentLoaderMock()
        
        if fetchError {
            folderContentLoaderMock.getContentPathContinuationTokenPageSizeConfigError = Copy.testError
        } else {
            folderContentLoaderMock.getContentPathContinuationTokenPageSizeConfigResult =
                FolderContentPage(
                    entries: hasEntries ? Copy.pageEntries : [],
                    nextContinuationToken: hasNextPage ? Copy.pageContinuationToken : nil
                )
        }
        
        let sut = ApiEntryPageSequence(
            path: Copy.path,
            pageSize: Copy.pageSize,
            apiConfigProvider: apiConfigProviderMock,
            folderContentLoader: folderContentLoaderMock
        ).makeAsyncIterator()
        
        return (
            sut,
            apiConfigProviderMock,
            folderContentLoaderMock
        )
    }
    
    private enum Copy {
        static let path = "Folder1/Folder2/Folder3"
        static let pageSize = 23
        static let pageContinuationToken = TestApiResponses.testContinuationToken
        static let testError = NSError.mock
        static let pageEntries = [Entry].mock
        static let config = ApiConfig.mock
    }
}
