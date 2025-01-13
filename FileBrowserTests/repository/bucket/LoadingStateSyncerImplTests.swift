//
//  LoadingStateSyncerImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class LoadingStateSyncerImplTests: XCTestCase {
    func testSyncedLoadingStates_nonEmptyListAndStatesFetchSuccess_sameEntriesWithUpdatedStatesReturned() async throws {
        let (sut, loadingRegistryMock) = createSut()
        loadingRegistryMock.downloadingStatesForPathsInBucketNameResult = Copy.testTargetStates
        
        let result = try await sut.syncedLoadingStates(for: Copy.testEntries)
        
        let expectedResult = Copy.testEntries.enumerated().map { index, entry in
            entry.copy(loadingState: Copy.testTargetStates[index])
        }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSyncedLoadingStates_nonEmptyListAndStatesFetchSuccess_singleStatesFetchForThePathsInBundleMade() async throws {
        let (sut, loadingRegistryMock) = createSut()
        loadingRegistryMock.downloadingStatesForPathsInBucketNameResult = Copy.testTargetStates
        
        _ = try await sut.syncedLoadingStates(for: Copy.testEntries)
        
        XCTAssertEqual(loadingRegistryMock.downloadingStatesForPathsInBucketNameCalls.count, 1)
        XCTAssertEqual(loadingRegistryMock.downloadingStatesForPathsInBucketNameCalls.last?.relativeFilePaths, Copy.testEntries.map(\.path))
        XCTAssertEqual(loadingRegistryMock.downloadingStatesForPathsInBucketNameCalls.last?.bucketName, Copy.testBucketName)
    }
    
    func testSyncedLoadingStates_emptyList_emptyEntriesListReturned() async throws {
        let (sut, loadingRegistryMock) = createSut()
        loadingRegistryMock.downloadingStatesForPathsInBucketNameResult = []
        
        let result = try await sut.syncedLoadingStates(for: [])
        
        XCTAssertEqual(loadingRegistryMock.downloadingStatesForPathsInBucketNameCalls.count, 0)
        XCTAssertEqual(result, [])
    }
    
    func testSyncedLoadingStates_emptyList_noStatesFetch() async throws {
        let (sut, loadingRegistryMock) = createSut()
        loadingRegistryMock.downloadingStatesForPathsInBucketNameResult = []
        
        _ = try await sut.syncedLoadingStates(for: [])
        
        XCTAssertEqual(loadingRegistryMock.downloadingStatesForPathsInBucketNameCalls.count, 0)
    }

    
    func testSyncedLoadingStates_nonEmptyListAndFetchError_errorReturned() async throws {
        let (sut, loadingRegistryMock) = createSut()
        loadingRegistryMock.downloadingStatesForPathsInBucketNameError = Copy.testError
        
        await assertThrowsAsyncError(
            try await sut.syncedLoadingStates(for: Copy.testEntries)
        ) { error in
            XCTAssertEqual(error as NSError, Copy.testError)
        }
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        LoadingStateSyncerImpl,
        LoadingRegistryMock
    ) {
        let loadingRegistryMock = LoadingRegistryMock()
        
        let sut = LoadingStateSyncerImpl(
            loadingRegistry: loadingRegistryMock
        )
        
        return (
            sut,
            loadingRegistryMock
        )
    }
    
    private enum Copy {
        static let testTargetStates: [LoadingState] = [
            .loading, .notLoaded, .loaded
        ]
        static let testEntries = [
            Entry(
                name: "name1.ext1",
                path: "a/b/name1.ext1",
                bucketName: testBucketName,
                isFolder: false,
                loadingState: .notLoaded
            ),
            Entry(
                name: "name2",
                path: "a/b/name2",
                bucketName: testBucketName,
                isFolder: true,
                loadingState: .notLoaded
            ),
            Entry(
                name: "name3.ext2",
                path: "a/b/name3.ext2",
                bucketName: testBucketName,
                isFolder: false,
                loadingState: .notLoaded
            )
        ]
        static let testBucketName = "testBucketName"
        static let testError = NSError(domain: "testError", code: 123)
    }
}
