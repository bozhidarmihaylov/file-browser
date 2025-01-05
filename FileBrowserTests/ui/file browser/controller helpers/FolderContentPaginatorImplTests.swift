//
//  FolderContentPaginatorImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FolderContentPaginatorImplTests: XCTestCase {
    func testLoadMore_calledTwice_oncePerformed() async throws {
        let (sut, taskLauncherMock, input, _) = createSut()
        
        await loadMore(
            sut,
            taskLauncherMock: taskLauncherMock,
            callTimes: 2
        )

        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        XCTAssertEqual(input.loadNextPageCallCount, 1)
    }
    
    func testLoadMore_notLoadedAllPages_outputDidStartLoadingCalled() async throws {
        let (sut, taskLauncherMock, input, output) = createSut()
        
        await loadMore(sut, taskLauncherMock: taskLauncherMock)

        XCTAssertEqual(input.loadNextPageCallCount, 1)
        XCTAssertEqual(output.didStartLoadingNewPageCallCount, 1)
    }
    
    func testLoadMore_loadingPageError_errorReturned() async throws {
        let (sut, taskLauncherMock, input, output) = createSut(
            hasLoadNextPageError: true
        )
        
        await loadMore(sut, taskLauncherMock: taskLauncherMock)
        
        XCTAssertEqual(output.didFinishLoadingNewPageWithResultCalls.count, 1)
        
        if case .failure(let error) = output.didFinishLoadingNewPageWithResultCalls.last {
            XCTAssertEqual(error as NSError, Copy.loadNextPageError)
        } else {
            XCTFail("Expected failure, got success")
        }

        XCTAssertEqual(input.loadNextPageCallCount, 1)
        XCTAssertEqual(output.didStartLoadingNewPageCallCount, 1)
    }
    
    func testLoadMore_success_entriesReturned() async throws {
        let (sut, taskLauncherMock, input, output) = createSut()
        
        await loadMore(sut, taskLauncherMock: taskLauncherMock)
        
        XCTAssertEqual(output.didFinishLoadingNewPageWithResultCalls.count, 1)
        
        if case .success(let entries) = output.didFinishLoadingNewPageWithResultCalls.last {
            XCTAssertEqual(entries, Copy.entires)
        } else {
            XCTFail("Expected success, got failure")
        }

        XCTAssertEqual(input.loadNextPageCallCount, 1)
        XCTAssertEqual(output.didStartLoadingNewPageCallCount, 1)
    }
    
    func testLoadMore_twoChainedCallsAndEmptyFirstPage_loadsOnce() async throws {
        let (sut, taskLauncherMock, input, output) = createSut(
            haveMoreEntries: false
        )
        
        await loadMore(sut, taskLauncherMock: taskLauncherMock)
        await loadMore(sut, taskLauncherMock: taskLauncherMock)
        
        XCTAssertEqual(output.didStartLoadingNewPageCallCount, 1)
        XCTAssertEqual(input.loadNextPageCallCount, 1)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        hasLoadNextPageError: Bool = false,
        haveMoreEntries: Bool = true
    ) -> (
        FolderContentPaginatorImpl,
        TaskLauncherMock,
        FolderContentPaginatorInputMock,
        FolderContentPaginatorOutputMock
    ) {
        let taskLauncherMock = TaskLauncherMock()
        let mainActorRunnerMock = MainActorRunnerMock()

        let input = FolderContentPaginatorInputMock()
        if hasLoadNextPageError {
            input.loadNextPageError = Copy.loadNextPageError
        } else {
            input.loadNextPageResult = haveMoreEntries ? Copy.entires : []
        }
        
        let output = FolderContentPaginatorOutputMock()

        let sut = FolderContentPaginatorImpl(
            taskLauncher: taskLauncherMock,
            mainActorRunner: mainActorRunnerMock
        )
        sut.input = input
        sut.output = output
        
        return (
            sut,
            taskLauncherMock,
            input,
            output
        )
    }
    
    private func loadMore(
        _ sut: FolderContentPaginatorImpl,
        taskLauncherMock: TaskLauncherMock,
        callTimes: Int = 1
    ) async {
        for _ in 0..<callTimes {
            sut.loadMore()
        }
              
        for task in taskLauncherMock.launchTasks {
            _ = await task.result
        }
    }
    
    private enum Copy {
        static let entires = [Entry].mock
        
        static let loadNextPageError = NSError(domain: "loadNextPageError", code: 1)
    }
}
