//
//  ApiBucketRepositoryFactoryImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class ApiBucketRepositoryFactoryImplTests: XCTestCase {
    func testCreateBucketRepository_called_apiBucketRepositoryImplReturned() throws {
        let sut = createSut()
        
        let result = try sut.createBucketRepository()
        
        XCTAssert(result is ApiBucketRepositoryImpl)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> ApiBucketRepositoryFactoryImpl {
        ApiBucketRepositoryFactoryImpl()
    }
}
