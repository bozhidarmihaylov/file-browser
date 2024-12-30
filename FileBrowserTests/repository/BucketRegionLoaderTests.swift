//
//  BucketRegionLoaderTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class BucketRegionLoaderTests: TestCase {
    func testLoadRegion_networkException_rethrowsIt() async throws {
        let (sut, httpClientMock) = createSut()
        
        httpClientMock.dataForRequestThrows(Copy.testError)
                
        await assertThrowsAsyncError(
            try await sut.loadRegion(with: Copy.testBucketName)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.testError)
        }
    }
    
    func testLoadRegion_correctResult_returnsIt() async throws {
        let (sut, httpClientMock) = createSut()
        
        httpClientMock.dataForRequestSuccess(result: Copy.successResult)
         
        let result = try await sut.loadRegion(with: Copy.testBucketName)

        XCTAssertEqual(result, Copy.testResultRegion)
    }
    
    func testLoadRegion_invalidBucketName_invalidBucketNameError() async throws {
        let (sut, httpClientMock) = createSut()
        
        httpClientMock.dataForRequestSuccess(result: Copy.successResult)
         
        await assertThrowsAsyncError(
            try await sut.loadRegion(with: Copy.invalidBucketName)
        ) { error in
            XCTAssert(error is BucketRegionLoaderError)
            XCTAssertEqual(error as? BucketRegionLoaderError, .invalidBucketName)
        }
    }
    
    func testLoadRegion_missingHeader_notFoundError() async throws {
        let (sut, httpClientMock) = createSut()
        
        httpClientMock.dataForRequestSuccess(result: Copy.notFoundResult)
        
        await assertThrowsAsyncError(
            try await sut.loadRegion(with: Copy.testBucketName)
        ) { error in
            XCTAssert(error is BucketRegionLoaderError)
            XCTAssertEqual(error as? BucketRegionLoaderError, .notFound)
        }
    }
    
    
    // MARK: Helper methods

    private func createSut() -> (BucketRegionLoader, HttpClientMock) {
        let httpClientMock = HttpClientMock()
        
        let sut = BucketRegionLoaderImpl(
            httpClient: httpClientMock
        )
        return (sut, httpClientMock)
    }
    
    private enum Copy {
        static let textUrl = URL(string: "https://\(testBucketName).s3.amazonaws.com")!
        static let invalidBucketName = "^"
        static let testBucketName = "testbucketName"
        static let testError = NSError(domain: "testError", code: 1)
        static let testResultRegion = "aws-test-region"
        
        static let successResult = (
            data: Data(),
            response: HTTPURLResponse(
                url: textUrl,
                statusCode: 200,
                httpVersion: "http/2.0",
                headerFields: [
                    "x-amz-bucket-region": testResultRegion
                ]
            )!
        )
        
        static let notFoundResult = (
            data: Data(),
            response: HTTPURLResponse(
                url: textUrl,
                statusCode: 200,
                httpVersion: "http/2.0",
                headerFields: [:]
            )!
        )
    }
}
