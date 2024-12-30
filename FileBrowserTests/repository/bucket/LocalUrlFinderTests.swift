//
//  LocalUrlFinderTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class LocalUrlFinderTest: XCTestCase {
    func testLocalUrForPathInBucketName_called_documentsSlashBucketSlashPathFileUrlReturned() {
        let (sut, fileSystemMock) = createSut()
        fileSystemMock.documentsDirectoryUrlResult = Copy.testDocumentsFolderUrl
        
        let result = sut.localUrl(
            for: Copy.testRelativePath,
            in: Copy.testBucketName
        )
    
        XCTAssertEqual(result, Copy.testAbsoluteUrl)
    }
    
    func testLocalPathForPathInBucketName_called_documentsSlashBucketSlashPathReturned() {
        let sut = LocalUrlFinderMock()
        
        sut.localUrlForRelativeFilePathAndBucketNameResult = Copy.testAbsoluteUrl
        
        let result = sut.localPath(
            for: Copy.testRelativePath,
            in: Copy.testBucketName
        )
        
        XCTAssertEqual(result, Copy.testAbsolutePath)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        LocalUrlFinderImpl,
        FileSystemMock
    ) {
        let fileSystemMock = FileSystemMock()
        
        let sut = LocalUrlFinderImpl(
            fileSystem: fileSystemMock
        )
        
        return (
            sut,
            fileSystemMock
        )
    }
    
    private enum Copy {
        static let testDocumentsFolderPath = "/TestFolder1/TestFolder2/TestFolder3"
        static let testDocumentsFolderUrl = URL(
            fileURLWithPath: testDocumentsFolderPath
        )

        static let testRelativePath = "FolderA/FolderB/File.ext"
        static let testBucketName = "TestBucket1"
        
        static let testAbsolutePath = [
            testDocumentsFolderPath,
            testBucketName,
            testRelativePath
        ].joined(separator: "/")
        static let testAbsoluteUrl = URL(
            fileURLWithPath: testAbsolutePath
        )
    }
}
