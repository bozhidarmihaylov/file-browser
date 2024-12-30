//
//  FolderContentLoaderImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FolderContentLoaderImplTests: XCTestCase {
    func testGetContent_success_forwardsInputToRequestFactory() async throws {
        let (sut, _, requestFactoryMock, _, _) = createSut()
        
        _ = try await getContent(sut: sut)
        
        XCTAssertEqual(requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigCalls.count, 1)
        XCTAssertEqual(requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigCalls.last?.folderPath, Copy.testPath)
        XCTAssertEqual(requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigCalls.last?.continuationToken, Copy.continuationToken)
        XCTAssertEqual(requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigCalls.last?.pageSize, Copy.pageSize)
        XCTAssertEqual(requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigCalls.last?.config, Copy.config)
    }
    
    func testGetContent_success_requestSendToHttpClient() async throws {
        let (sut, httpClientMock, _, _, _) = createSut()
        
        _ = try await getContent(sut: sut)
        
        XCTAssertEqual(httpClientMock.dataForRequestCalls.count, 1)
        XCTAssertEqual(httpClientMock.dataForRequestCalls.last, Copy.request)
    }
    
    func testGetContent_success_xmlResponseSentToXmlDecoder() async throws {
        let (sut, _, _, xmlDecoderMock, _) = createSut()
        
        _ = try await getContent(sut: sut)
        
        XCTAssertEqual(xmlDecoderMock.fromXmlDataCalls.count, 1)
        XCTAssertEqual(xmlDecoderMock.fromXmlDataCalls.last?.data, Copy.httpResultData)
        XCTAssertTrue(xmlDecoderMock.fromXmlDataCalls.last?.type == ListBucketResult.self)
    }
    
    func testGetContent_success_fileEntriesForwardedToStateSyncer() async throws {
        let (sut, _, _, _, stateSyncerMock) = createSut()
        
        _ = try await getContent(sut: sut)
        
        XCTAssertEqual(stateSyncerMock.syncedLoadingStatesForEntriesCalls.count, 1)
        XCTAssertEqual(stateSyncerMock.syncedLoadingStatesForEntriesCalls.last, Copy.stateSyncExpectedInput)
    }
    
    func testGetContent_successNoMorePages_sortedEntriesWithSyncedLoadingStatesReturned() async throws {
        let (sut, _, _, _, _) = createSut()
        
        let result = try await getContent(sut: sut)
        
        XCTAssertEqual(result.entries, Copy.expectedResult)
        XCTAssertNil(result.nextContinuationToken)
    }
    
    func testGetContent_successWithMorePages_sortedEntriesWithSyncedLoadingStatesReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            hasNextPage: true
        )
        
        let result = try await getContent(sut: sut)
        
        XCTAssertEqual(result.entries, Copy.expectedResult)
        XCTAssertEqual(result.nextContinuationToken, Copy.nextContinuationToken)
    }
    
    func testGetContent_httpError_errorReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            httpError: true
        )
        
        await assertThrowsAsyncError(
            try await getContent(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.httpError)
        }
    }
    
    func testGetContent_parseError_errorReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            parseError: true
        )
        
        await assertThrowsAsyncError(
            try await getContent(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.parseError)
        }

    }
    
    func testGetContent_stateSyncError_errorReturned() async throws {
        let (sut, _, _, _, _) = createSut(
            stateSyncError: true
        )
        
        await assertThrowsAsyncError(
            try await getContent(sut: sut)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.stateSyncError)
        }
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasNextPage: Bool = false,
        httpError: Bool = false,
        parseError: Bool = false,
        stateSyncError: Bool = false
    ) -> (
        FolderContentLoaderImpl,
        HttpClientMock,
        FolderContentRequestFactoryMock,
        XmlDecoderMock,
        LoadingStateSyncerMock
    ) {
        let httpClientMock = HttpClientMock()
        if httpError {
            httpClientMock.dataForRequestError = Copy.httpError
        } else {
            httpClientMock.dataForRequestResult = (Copy.httpResultData, Copy.httpResultResponse)
        }
        
        let requestFactoryMock = FolderContentRequestFactoryMock()
        requestFactoryMock.createListRequestWithPathContinuationTokenPageSizeConfigResult = Copy.request
        
        let xmlDecoderMock = XmlDecoderMock()
        if parseError {
            xmlDecoderMock.fromXmlDataError = Copy.parseError
        } else {
            xmlDecoderMock.fromXmlDataResult = 
                hasNextPage ? Copy.parseResultMorePages : Copy.parseResult
        }
        
        let loadingStateSyncerMock = LoadingStateSyncerMock()
        if stateSyncError {
            loadingStateSyncerMock.syncedLoadingStatesForEntriesError = Copy.stateSyncError
        } else {
            loadingStateSyncerMock.syncedLoadingStatesForEntriesResult = Copy.stateSyncResult
        }
        
        let sut = FolderContentLoaderImpl(
            httpClient: httpClientMock,
            requestFactory: requestFactoryMock,
            xmlDecoder: xmlDecoderMock,
            loadingStateSyncer: loadingStateSyncerMock
        )
        
        return (
            sut,
            httpClientMock,
            requestFactoryMock,
            xmlDecoderMock,
            loadingStateSyncerMock
        )
    }
    
    private func getContent(sut: FolderContentLoader) async throws -> FolderContentPage {
        try await sut.getContent(
            path: Copy.testPath,
            continuationToken: Copy.continuationToken,
            pageSize: Copy.pageSize,
            config: Copy.config
        )
    }
    
    private enum Copy {
        static let testPath = "folder1/folder2/folder3"
        static let continuationToken = "fj394hf092834fh"
        static let pageSize = 17
        static let url = URL(string: "https://some-test-bucket.s3.some-aws-region.amazonaws.com/?list-type=2&delimiter=%2F&prefix=some-folder%2F&max-keys=20")!
        static let request = URLRequest(url: url)
        static let config = ApiConfig.mock
        
        static let httpResultData = "<xml>some response</xml>"
            .data(using: .utf8)!
        static let httpResultResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        static let httpError = NSError(domain: "httpError", code: 1)
        
        static let parseResult = TestApiResponses.testListObjectsV2SinglePageResult
        static let parseResultMorePages =
            TestApiResponses.testListObjectsV2FirstPageResult
        static let nextContinuationToken = TestApiResponses.firstPageNextContinuationToken
        static let parseError = NSError(domain: "parseError", code: 2)
        
        static let stateSyncExpectedInput: [Entry] = [
            Entry(
                name: "book.mixu.net-Distributed systems.pdf",
                path: "book.mixu.net-Distributed systems.pdf",
                bucketName: "test-bucket", 
                isFolder: false, 
                loadingState: .notLoaded
            ), Entry(
                name: "firewall-blocked-2021-05-10.csv", 
                path: "firewall-blocked-2021-05-10.csv",
                bucketName: "test-bucket", 
                isFolder: false, 
                loadingState: .notLoaded
            ), Entry(
                name: "firewall-blocked-2021-05-15.csv",
                path: "firewall-blocked-2021-05-15.csv", 
                bucketName: "test-bucket", 
                isFolder: false, 
                loadingState: .notLoaded
            ), Entry(
                name: "firewall-blocked-2021-05-20.csv", 
                path: "firewall-blocked-2021-05-20.csv", 
                bucketName: "test-bucket", 
                isFolder: false, 
                loadingState: .notLoaded
            )
        ]
        static let syncStateResultStates: [LoadingState] = [
            .loading,
            .loaded,
            .notLoaded,
            .loading
        ]
        static let stateSyncResult: [Entry] = stateSyncExpectedInput
            .enumerated()
            .map { offset, element in
                element.copy(
                    loadingState: syncStateResultStates[offset]
                )
            }
        static let stateSyncError = NSError(domain: "stateSyncError", code: 3)
        static let expectedResult = [
            Entry(
                name: "EmptyFolder",
                path: "EmptyFolder/",
                bucketName: "test-bucket",
                isFolder: true,
                loadingState: .notLoaded
            ), Entry(
                name: "Images",
                path: "Images/",
                bucketName: "test-bucket",
                isFolder: true,
                loadingState: .notLoaded
            ), Entry(
                name: "Videos",
                path: "Videos/",
                bucketName: "test-bucket",
                isFolder: true,
                loadingState: .notLoaded
            ), Entry(
                name: "book.mixu.net-Distributed systems.pdf",
                path: "book.mixu.net-Distributed systems.pdf",
                bucketName: "test-bucket",
                isFolder: false,
                loadingState: .loading
            ), Entry(
                name: "firewall-blocked-2021-05-10.csv",
                path: "firewall-blocked-2021-05-10.csv",
                bucketName: "test-bucket",
                isFolder: false,
                loadingState: .loaded
            ), Entry(
                name: "firewall-blocked-2021-05-15.csv",
                path: "firewall-blocked-2021-05-15.csv",
                bucketName: "test-bucket",
                isFolder: false,
                loadingState: .notLoaded
            ), Entry(
                name: "firewall-blocked-2021-05-20.csv",
                path: "firewall-blocked-2021-05-20.csv",
                bucketName: "test-bucket",
                isFolder: false,
                loadingState: .loading
            ), Entry(
                name: "jdk-master",
                path: "jdk-master/",
                bucketName: "test-bucket",
                isFolder: true,
                loadingState: .notLoaded
            )
        ]
    }
}
