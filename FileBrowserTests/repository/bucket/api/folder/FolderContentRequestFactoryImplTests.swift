//
//  FolderContentRequestFactoryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FolderContentRequestFactoryImplTests: XCTestCase {
    func testCreateListRequest_noContinuationTokenProvided_paramsSetIntoTheRequestUrl() {
        let (sut, _) = createSut()
        
        let request = createRequest(sut: sut, includeContinuationToken: false)
        
        XCTAssertEqual(request.url, Copy.expectedNoContinuationTokenUrl)
    }
    
    func testCreateListRequest_continuationTokenProvided_paramsSetIntoTheRequestUrl() {
        let (sut, _) = createSut()
        
        let request = createRequest(sut: sut, includeContinuationToken: true)
        
        XCTAssertEqual(request.url, Copy.expectedContinuationTokenUrl)
    }
    
    func testCreateListRequest_continuationTokenProvided_resultRequestIsSigned() {
        let (sut, requestSignerMock) = createSut()
        requestSignerMock.signRequestWithConfigOnCall = { request, apiConfig in
            request.setValue(
                Copy.testSignatureHeaderValue,
                forHTTPHeaderField: Copy.testSignatureHeaderName
            )
        }
        
        let request = createRequest(sut: sut, includeContinuationToken: true)
        
        XCTAssertEqual(requestSignerMock.signRequestWithConfigCall.count, 1)
        XCTAssertEqual(requestSignerMock.signRequestWithConfigCall.last?.request.url, request.url)
        XCTAssertEqual(request.value(forHTTPHeaderField: Copy.testSignatureHeaderName), Copy.testSignatureHeaderValue)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        FolderContentRequestFactoryImpl,
        RequestSignerMock
    ) {
        let requestSignerMock = RequestSignerMock()
        
        let sut = FolderContentRequestFactoryImpl(
            requestSigner: requestSignerMock
        )
        
        return (
            sut,
            requestSignerMock
        )
    }
    
    private func createRequest(
        sut: FolderContentRequestFactory,
        includeContinuationToken: Bool
    ) -> URLRequest {
        sut.createListRequest(
            folderPath: Copy.folderPath,
            continuationToken: includeContinuationToken ? Copy.continuationToken : nil,
            pageSize: Copy.pageSize,
            with: Copy.apiConfig
        )
    }
    
    private enum Copy {
        static let folderPath = "folder1/folder2/folder3"
        static let continuationToken = "1JyViVenJMqYu4nWyduHLoMvbM2Sez1ImhttPOmZfmwDKdPWYporw6MlOUNSi+2LoS49+mlDpvUM="
        static let pageSize = 23
        static let credential = ApiCredential(
            accessKey: "testAccessKey", 
            secretKey: "testSecretKey"
        )
        static let bucket = Bucket(
            name: "bucket123",
            region: "aws-test-region"
        )
        static let expectedNoContinuationTokenUrl = URL(string: "https://bucket123.s3.aws-test-region.amazonaws.com/?list-type=2&delimiter=/&prefix=folder1/folder2/folder3&max-keys=23")
        static let expectedContinuationTokenUrl = URL(string: "https://bucket123.s3.aws-test-region.amazonaws.com/?list-type=2&continuation-token=1JyViVenJMqYu4nWyduHLoMvbM2Sez1ImhttPOmZfmwDKdPWYporw6MlOUNSi+2LoS49+mlDpvUM%3D&delimiter=/&prefix=folder1/folder2/folder3&max-keys=23")
        static let apiConfig = ApiConfig(
            credential: credential,
            bucket: bucket
        )
        static let testSignatureHeaderName = "testSignatureHeader"
        static let testSignatureHeaderValue = "testSignatureHeaderValue"
    }
}
