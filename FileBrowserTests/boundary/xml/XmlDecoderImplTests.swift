//
//  XmlDecoderImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class XmlDecoderImplTests: XCTestCase {
    func testFromXmlData_s3XmlSinglePageData_parsedSuccessfully() throws {
        let sut = createSut()
        
        let result = try sut.fromXmlData(Copy.testSinglePageData, type: ListBucketResult.self)
        
        XCTAssertEqual(result, Copy.testSinglePageResult)
    }
    
    func testFromXmlData_s3XmlFirstPageData_parsedSuccessfully() throws {
        let sut = createSut()
        
        let result = try sut.fromXmlData(Copy.testFirstPageData, type: ListBucketResult.self)
        
        XCTAssertEqual(result, Copy.testFirstPageResult)
    }
    
    func testFromXmlData_s3XmlMiddlePageData_parsedSuccessfully() throws {
        let sut = createSut()
        
        let result = try sut.fromXmlData(Copy.testMiddlePageData, type: ListBucketResult.self)
        
        XCTAssertEqual(result, Copy.testMiddlePageResult)
    }
    
    func testFromXmlData_s3XmlLastPageData_parsedSuccessfully() throws {
        let sut = createSut()
        
        let result = try sut.fromXmlData(Copy.testLastPageData, type: ListBucketResult.self)
        
        XCTAssertEqual(result, Copy.testLastPageResult)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> XmlDecoderImpl {
        XmlDecoderImpl()
    }
    
    private enum Copy {
        static let testSinglePageData = TestApiResponses.testListObjectsV2ResponseSinglePageData
        static let testSinglePageResult =
            TestApiResponses.testListObjectsV2SinglePageResult
        
        static let testFirstPageData = TestApiResponses.testListObjectsV2ResponseFirstPageData
        static let testFirstPageResult =
            TestApiResponses.testListObjectsV2FirstPageResult
        
        static let testMiddlePageData = TestApiResponses.testListObjectsV2ResponseMiddlePageData
        static let testMiddlePageResult =
            TestApiResponses.testListObjectsV2MiddlePageResult
        
        static let testLastPageData = TestApiResponses.testListObjectsV2ResponseLastPageData
        static let testLastPageResult =
            TestApiResponses.testListObjectsV2LastPageResult
    }
}
