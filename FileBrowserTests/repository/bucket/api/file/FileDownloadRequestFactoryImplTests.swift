//
//  FileDownloadRequestFactoryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileDownloadRequestFactoryImplTest: XCTestCase {
    func testCreateDownloadRequest_pathNotStartingWithSlash_paramsSetIntoTheRequestUrl() {
        let (sut, _) = createSut()
        
        let request = sut.createDownloadRequest(
            filePath: Copy.filePath,
            with: Copy.config
        )
        XCTAssertEqual(request.url, Copy.expectedRequestUrl)
    }
    
    func testCreateDownloadRequest_pathStartingWithSlash_paramsSetIntoTheRequestUrl() {
        let (sut, _) = createSut()
        
        let request = sut.createDownloadRequest(
            filePath: Copy.filePathStaringWithSlash,
            with: Copy.config
        )
        XCTAssertEqual(request.url, Copy.expectedRequestUrl)
    }

    func testCreateDownloadRequest_called_resultRequestIsSigned() {
        let (sut, requestSignerMock) = createSut()
        requestSignerMock.signRequestWithConfigOnCall = { request, apiConfig in
            request.setValue(
                Copy.testSignatureHeaderValue,
                forHTTPHeaderField: Copy.testSignatureHeaderName
            )
        }
        
        let request = sut.createDownloadRequest(
            filePath: Copy.filePath,
            with: Copy.config
        )
        
        XCTAssertEqual(requestSignerMock.signRequestWithConfigCall.count, 1)
        XCTAssertEqual(requestSignerMock.signRequestWithConfigCall.last?.request.url, request.url)
        XCTAssertEqual(request.value(forHTTPHeaderField: Copy.testSignatureHeaderName), Copy.testSignatureHeaderValue)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        FileDownloadRequestFactoryImpl,
        RequestSignerMock
    ) {
        let requestSignerMock = RequestSignerMock()
        
        let sut = FileDownloadRequestFactoryImpl(
            requestSigner: requestSignerMock
        )
        
        return (
            sut,
            requestSignerMock
        )
    }
    
    private enum Copy {
        static let filePath = "folder1/folder2/f1.pdf"
        static let filePathStaringWithSlash = "/folder1/folder2/f1.pdf"
        static let config = ApiConfig.mock
        
        static let expectedRequestUrl = URL(string: "https://test-bucket.s3.test-aws-region.amazonaws.com/folder1/folder2/f1.pdf")!
        
        static let testSignatureHeaderName = "testSignatureHeader"
        static let testSignatureHeaderValue = "testSignatureHeaderValue"
    }
}
