//
//  FolderContentImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FolderContentImplTests: XCTestCase {
    func testNumberOfEntries_calledAsFirstCall_zeroReturned() {
        let (sut, _, _) = createSut()
        
        let result = sut.numberOfEntries()
        
        XCTAssertEqual(result, 0)
    }
    
    func testNumberOfEntries_calledAfterTwoAppendCall_combinedCountReturned() {
        let (sut, _, _) = createSut()
        
        sut.append(entries: Copy.entriesPage1)
        sut.append(entries: Copy.entriesPage2)
        
        let result = sut.numberOfEntries()
        
        XCTAssertEqual(result, Copy.entriesPage1.count + Copy.entriesPage2.count)
    }
    
    func testEntryAtIndex_called_entryAtIndexReturned() {
        let (sut, _, _) = createSut()
        sut.append(entries: Copy.entries)
        
        let result = sut.entry(at: 1)
        
        XCTAssertEqual(result, Copy.entries[1])
    }
    
    func testAppendEntries_calledTwice_combinedEntriesAppended() {
        let (sut, _, _) = createSut()

        sut.append(entries: Copy.entriesPage1)
        sut.append(entries: Copy.entriesPage2)

        XCTAssertEqual(sut.entries, Copy.entriesPage1 + Copy.entriesPage2)
    }
    
    func testAppendEntries_called_outputDidAppendEntriesCalled() {
        let (sut, _, folderContentOutputMock) = createSut()

        sut.append(entries: Copy.entries)

        XCTAssertEqual(folderContentOutputMock.didAppendEntriesCalls.count, 1)
        XCTAssertEqual(folderContentOutputMock.didAppendEntriesCalls.last, Copy.entries)
    }
    
    func testSyncLoadingStates_success_loadingStatesSynced() async throws {
        let (sut, loadingStateSyncerMock, _) = createSut()
        sut.append(entries: Copy.entries)

        try await sut.syncLoadingStates()
        
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.count, 1)
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.last, Copy.entries)
        
        XCTAssertEqual(sut.entries, Copy.syncedEntries)
    }
    
    func testSyncLoadingStates_successSystemDealloc_loadingStatesSynced() async throws {
        let (sut, loadingStateSyncerMock, _) = createSut()
        sut.append(entries: Copy.entries)

        try await sut.syncLoadingStates()
        
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.count, 1)
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.last, Copy.entries)
        
        XCTAssertEqual(sut.entries, Copy.syncedEntries)
    }
    
    func testSyncLoadingStates_success_outputDidSyncLoadingStatesCalled() async throws {
        let (sut, _, folderContentOutputMock) = createSut()
        sut.append(entries: Copy.entries)

        try await sut.syncLoadingStates()
        
        XCTAssertEqual(folderContentOutputMock.didSyncLoadingStatesCallCount, 1)
    }
    
    func testSyncLoadingStates_syncLoadingStatesError_errorReturned() async throws {
        let (sut, loadingStateSyncerMock, folderContentOutputMock) = createSut(
            hasSyncLoadingStatesError: true
        )
        sut.append(entries: Copy.entries)

        await assertThrowsAsyncError(
            try await sut.syncLoadingStates()
        ) { error in
            XCTAssertEqual(error as NSError, Copy.syncLoadingStatesError)
        }
        
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.count, 1)
        XCTAssertEqual(loadingStateSyncerMock.syncedLoadingStatesForEntriesCalls.last, Copy.entries)
        
        XCTAssertEqual(sut.entries, Copy.entries)
        
        XCTAssertEqual(folderContentOutputMock.didSyncLoadingStatesCallCount, 0)
    }
    
    func testSetLoadingState_found_loadingStateSet() {
        let (sut, _, _) = createSut()
        sut.append(entries: Copy.entries)
        
        sut.setLoadingState(.loaded, at: Copy.entries[1].path)
        
        XCTAssertEqual(sut.entries[1].loadingState, .loaded)
    }
    
    func testSetLoadingState_found_outputDidUpdateLoadingStateCalled() {
        let (sut, _, folderContentOutputMock) = createSut()
        sut.append(entries: Copy.entries)
        
        sut.setLoadingState(.loaded, at: Copy.entries[1].path)
        
        XCTAssertEqual(folderContentOutputMock.didUpdateLoadingStateAtIndexCalls.count, 1)
        XCTAssertEqual(folderContentOutputMock.didUpdateLoadingStateAtIndexCalls.last, 1)
    }
    
    func testSetLoadingState_notFound_outputDidUpdateLoadingStateNotCalled() {
        let (sut, _, folderContentOutputMock) = createSut()
        sut.append(entries: Copy.entries)
        
        sut.setLoadingState(.loaded, at: Copy.notFoundPath)
        
        XCTAssertEqual(folderContentOutputMock.didUpdateLoadingStateAtIndexCalls.count, 0)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasSyncLoadingStatesError: Bool = false,
        useRealMainActorRunner: Bool = false
    ) -> (
        FolderContentImpl,
        LoadingStateSyncerMock,
        FolderContentOutputMock
    ) {
        let loadingStateSyncerMock = LoadingStateSyncerMock()
        if hasSyncLoadingStatesError {
            loadingStateSyncerMock.syncedLoadingStatesForEntriesError = Copy.syncLoadingStatesError
        } else {
            loadingStateSyncerMock.syncedLoadingStatesForEntriesResult = Copy.syncedEntries
        }
        
        let mainActorRunnerMock = MainActorRunnerMock()
        
        let folderContentOutputMock = FolderContentOutputMock()
        
        let sut = FolderContentImpl(
            path: Copy.path,
            loadingStateSyncer: loadingStateSyncerMock,
            mainActorRunner: useRealMainActorRunner
                ? MainActorRunnerImpl()
                : mainActorRunnerMock
        )
        sut.output = folderContentOutputMock
        
        return (
            sut,
            loadingStateSyncerMock,
            folderContentOutputMock
        )
    }
    
    private enum Copy {
        static let path = "folder1/folder2"
        
        static let entries = [Entry].mock
                
        static let entriesPage1 = Array(entries[0...0])
        static let entriesPage2 = Array(entries[1...])
        
        static let syncedEntriesStates: [LoadingState] = [
            .loaded,
            .loading,
            .notLoaded
        ]
        static let syncedEntries = entries
            .enumerated()
            .map { offset, element in
                element.copy(
                    loadingState: syncedEntriesStates[offset]
                )
            }

        static let syncLoadingStatesError = NSError(domain: "syncLoadingStatesError", code: 1)
        
        static let notFoundPath = "notFound/path"
    }
}
