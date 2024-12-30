//
//  RequestSignerImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class RequestSignerImplTests: XCTestCase {
    func testSign_request_urlElementsAreEscaped() {
        Copy.testDataList.forEach { testData in
            let (sut, _) = createSut()
            
            var request = testData.request
            sut.sign(
                request: &request,
                with: Copy.config
            )
            
            let updatedUrl = request.url
            
            XCTAssertEqual(updatedUrl, testData.updatedUrl)
        }
    }
    
    func testSign_request_hostHeaderIsSet() {
        Copy.testDataList.forEach { testData in
            let (sut, _) = createSut()
            
            var request = testData.request
            sut.sign(
                request: &request,
                with: Copy.config
            )
            
            let dateHeaderValue = request.value(
                forHTTPHeaderField: Copy.hostHeaderName
            )
            
            XCTAssertEqual(dateHeaderValue, testData.hostHeaderValue)
        }
    }
    
    func testSign_request_xAmzDateHeaderSetToCurrentTime() {
        Copy.testDataList.forEach { testData in
            let (sut, _) = createSut()
            
            var request = testData.request
            
            sut.sign(
                request: &request,
                with: Copy.config
            )
            
            let hostHeaderValue = request.value(
                forHTTPHeaderField: Copy.xAmzDateHeaderName
            )
            
            XCTAssertEqual(hostHeaderValue, Copy.xAmzDateHeaderValue)
        }
    }
    
    func testSign_request_authorizationHeaderSetWithTheSignature() {
        Copy.testDataList.forEach { testData in
            let (sut, _) = createSut()
            
            var request = testData.request
            sut.sign(
                request: &request,
                with: Copy.config
            )
            
            let hostHeaderValue = request.value(
                forHTTPHeaderField: Copy.authorizationHeaderName
            )
            
            XCTAssertEqual(hostHeaderValue, testData.authorizationHeaderValue)
        }
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        RequestSignerImpl,
        CurrentDateProviderMock
    ) {
        let currentDateProviderMock = CurrentDateProviderMock()
        currentDateProviderMock.currentDateResult = Copy.currentDate
        
        let sut = RequestSignerImpl(
            currentDateProvider: currentDateProviderMock
        )
        
        return (
            sut,
            currentDateProviderMock
        )
    }
    
    private struct TestData {
        let request: URLRequest
        let updatedUrl: URL
        let hostHeaderValue: String
        let authorizationHeaderValue: String
    }
    
    private enum Copy {
        static let currentDate = Date.mock
        static let config = ApiConfig.mock
        
        static let requestWithQueryArgsTestData = TestData(
            request: URLRequest(
                url: URL(string: "https://some-s3-bucket.s3.some-aws-region.amazonaws.com/?list-type=2&continuation-token=1t97ZF4ceRLR9RgCbXmQDTq9YTrUMpCF65XvgQ2fSRE5HFF2Frlern2utCHYhP0S3mr+7XR7idgc%3D&delimiter=/&prefix=some-folder/src/&max-keys=23")!
            ),
            updatedUrl: URL(string: "https://some-s3-bucket.s3.some-aws-region.amazonaws.com/?list-type=2&continuation-token=1t97ZF4ceRLR9RgCbXmQDTq9YTrUMpCF65XvgQ2fSRE5HFF2Frlern2utCHYhP0S3mr%2B7XR7idgc%3D&delimiter=%2F&prefix=some-folder%2Fsrc%2F&max-keys=23")!,
            hostHeaderValue: "some-s3-bucket.s3.some-aws-region.amazonaws.com",
            authorizationHeaderValue: "AWS4-HMAC-SHA256 Credential=access-key/20241121/test-aws-region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=f919a5692b345534158d6ca9ec23b36065d47fb5894a071042a283ce0d4df28f"
        )
        
        static let requestWithoutQueryArgs = TestData(
            request: URLRequest(
                url: URL(string: "https://some-s3-bucket2.s3.some-aws-region2.amazonaws.com/book.mixu.net-Distributed systems.pdf")!
            ),
            updatedUrl: URL(string:"https://some-s3-bucket2.s3.some-aws-region2.amazonaws.com/book.mixu.net-Distributed%20systems.pdf")!,
            hostHeaderValue: "some-s3-bucket2.s3.some-aws-region2.amazonaws.com",
            authorizationHeaderValue: "AWS4-HMAC-SHA256 Credential=access-key/20241121/test-aws-region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=b9d306d5be4b4dac8d1580415780168910be6d04a63e7aa95b87161ab1483291"
        )
        
        static let testDataList = [
            requestWithQueryArgsTestData,
            requestWithoutQueryArgs
        ]
        
        static let hostHeaderName = "Host"
        static let xAmzDateHeaderName = "X-Amz-Date"
        static let xAmzDateHeaderValue = "20241121T141441Z"
        static let authorizationHeaderName = "Authorization"
    }
}
