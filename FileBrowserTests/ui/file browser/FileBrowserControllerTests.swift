//
//  FileBrowserControllerTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileBrowserControllerTests: XCTestCase {
    
    // MARK: onInit()
    
    func testOnInit_called_subsribesToWillEnterForegroundNotification() throws {
        let (sut, _, _, _, _, _, _, _, noteSubject, _, _, _, _, _, _) = createSut()

        sut.onInit()
        
        let noteSubjectMock = noteSubject as? NotificationSubjectMock
        
        XCTAssertEqual(noteSubjectMock?.subscribeNameObjectOnEventCalls.count, 1)
        XCTAssertEqual(noteSubjectMock?.subscribeNameObjectOnEventCalls.last?.name,
                       Copy.willEnterBackgroundNotificationName)
        XCTAssertNil(noteSubjectMock?.subscribeNameObjectOnEventCalls.last?.object)
    }
    
    func testOnInit_enterForegroundEvent_loadingStatesSyncedWithView() async throws {
        let (sut, folderContentMock, _, _, _, _, _, _, noteSubject, _, taskLauncherMock, _, _, _, viewMock) = createSut(
            userRealNotificationSubject: true
        )

        sut.onInit()
        
        noteSubject.send(name: Copy.willEnterBackgroundNotificationName)
        
        await _ = taskLauncherMock.launchTasks.last?.result
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        XCTAssertEqual(folderContentMock.syncLoadingStatesCallCount, 1)
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls.count, 1)
    }
    
    func testOnInit_enterForegroundEventAndSyncLoadingStatesError_accessoryViewsNotUpdated() async throws {
        let (sut, folderContentMock, _, _, _, _, _, _, noteSubject, _, taskLauncherMock, _, _, _, viewMock) = createSut(
            userRealNotificationSubject: true,
            hasSyncLoadingStatesError: true
        )

        sut.onInit()
        
        noteSubject.send(name: Copy.willEnterBackgroundNotificationName)
        
        let result = await taskLauncherMock.launchTasks.last?.result
        
        if case .failure(let error) = result {
            XCTAssertEqual(error as NSError, Copy.loadingStatesError)
        } else {
            XCTFail("Expected failure, success received")
        }
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        XCTAssertEqual(folderContentMock.syncLoadingStatesCallCount, 1)
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls.count, 0)
    }
    
    // MARK: onViewAppeared()
    
    func testOnViewAppeared_called_loadingStatesSyncedWithView() async throws {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, taskLauncherMock, _, _, _, viewMock) = createSut()

        sut.onViewAppeared()
        
        await _ = taskLauncherMock.launchTasks.last?.result
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        XCTAssertEqual(folderContentMock.syncLoadingStatesCallCount, 1)
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls.count, 1)
    }
    
    func testOnViewAppeared_syncLoadingStatesError_loadingStatesNotSyncedWithView() async throws {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, taskLauncherMock, _, _, _, viewMock) = createSut(
            hasSyncLoadingStatesError: true
        )

        sut.onViewAppeared()
        
        let result = await taskLauncherMock.launchTasks.last?.result
        
        if case .failure(let error) = result {
            XCTAssertEqual(error as NSError, Copy.loadingStatesError)
        } else {
            XCTFail("Expected failure, success received")
        }
        
        XCTAssertEqual(taskLauncherMock.launchTasks.count, 1)
        XCTAssertEqual(folderContentMock.syncLoadingStatesCallCount, 1)
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls.count, 0)
    }
    
    // MARK: onDeinit()
    
    func testOnDeinit_called_enterForegroundSubscriptionCanceled() {
        let (sut, _, _, _, _, _, _, _, noteSubject, _, _, _, _, _, _) = createSut()
        let subscription = (noteSubject as? NotificationSubjectMock)?
            .subscribeNameObjectOnEventResult as? CancelllableMock
        
        sut.onInit()
        sut.onDeinit()
                
        XCTAssertEqual(subscription?.cancelCallsCount, 1)
    }
    
    // MARK: onViewLoaded()
    
    func testOnViewLoaded_called_contentPageLoadingStarted() {
        let (sut, _, _, _, bucketRepositoryMock, _, _, contentPaginatorMock, _, _, _, _, _, _, _) = createSut()
        
        sut.onViewLoaded()
        
        XCTAssertEqual(bucketRepositoryMock.getContentWithPathCalls.count, 1)
        XCTAssertEqual(bucketRepositoryMock.getContentWithPathCalls.last, Copy.path)
        
        XCTAssertEqual(contentPaginatorMock.loadMoreCallCount, 1)
    }
    
    // MARK: onRightButtonItemTap()
    
    func testOnRightButtonItemTap_called_sentsItToNavigator() {
        let (sut, _, navigatorMock, _, _, _, _, _, _, _, _, _, _, _, _) = createSut()
        
        sut.onRightButtonItemTap()
        
        XCTAssertEqual(navigatorMock.onRightButtonItemTapCallCount, 1)
    }
    
    // MARK: onCellTap(at:)

    func testOnCellTap_called_cellIsDeselected() {
        for isFolder in [false, true] {
            let (sut, _, _, _, _, _, _, _, _, _, _, _, _, _, viewMock) = createSut()
            
            let indexPath = isFolder
                ? Copy.folderIndexPath
                : Copy.fileIndexPath
            
            sut.onCellTap(at: indexPath)
            
            XCTAssertEqual(viewMock.deselectCellAtIndexPathCalls.count, 1)
            XCTAssertEqual(viewMock.deselectCellAtIndexPathCalls.last, indexPath)
        }
    }
    
    func testOnCellTap_isFolder_navigated() {
        let (sut, _, navigatorMock, _, _, _, _, _, _, _, _, _, _, _, _) = createSut()
        
        let indexPath = Copy.folderIndexPath
        sut.onCellTap(at: indexPath)
        
        XCTAssertEqual(navigatorMock.goToFileCalls.count, 0)
        XCTAssertEqual(navigatorMock.goToFolderCalls.count, 1)
        XCTAssertEqual(navigatorMock.goToFolderCalls.last, Copy.folder)
    }
    
    func testOnCellTap_notLoadedFile_notNavigated() {
        for loadingState: LoadingState in [.notLoaded, .loading] {
            let (sut, _, navigatorMock, _, _, _, _, _, _, _, _, _, _, _, _) = createSut(
                fileLoadingState: loadingState
            )

            let indexPath = Copy.fileIndexPath
            sut.onCellTap(at: indexPath)
            
            XCTAssertEqual(navigatorMock.goToFolderCalls.count, 0)
            XCTAssertEqual(navigatorMock.goToFileCalls.count, 0)
        }
    }
    
    func testOnCellTap_loadedFile_navigated() {
        let (sut, folderContentMock, navigatorMock, _, _, _, _, _, _, _, _, _, _, _, _) = createSut()
        
        let entry = Copy.file.copy(loadingState: .loaded)
        
        folderContentMock.entryAtIndexClosure = { _ in entry }
        let indexPath = Copy.fileIndexPath
        
        sut.onCellTap(at: indexPath)
        
        XCTAssertEqual(navigatorMock.goToFolderCalls.count, 0)
        XCTAssertEqual(navigatorMock.goToFileCalls.count, 1)
        XCTAssertEqual(navigatorMock.goToFileCalls.last, entry)
    }
    
    // MARK: onCellAccessoryTap(at:)
    
    func testOnCellAccessoryTap_called_setToLoadingState() {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, _, _, _, _, viewMock) = createSut()
        
        sut.onCellAccessoryTap(at: Copy.fileIndexPath)
                
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.first?.loadingState, .loading)
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.first?.path, Copy.file.path)
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls.first, [Copy.fileIndexPath])
    }
    
    func testOnCellAccessoryTap_downloadSuccess_setToLoadedState() async {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, taskLauncherMock, _, _, _, viewMock) = createSut()
        
        let indexPath = Copy.fileIndexPath
        sut.onCellAccessoryTap(at: indexPath)
        
        _ = await taskLauncherMock.launchTasks.last?.result
        
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.map (\.loadingState), [.loading, .loaded])
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.map(\.path), Array(repeating: Copy.file.path, count: 2))
        
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls, [[indexPath], [indexPath]])
    }
    
    func testOnCellAccessoryTap_downloadFailed_setToNotLoadedState() async {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, taskLauncherMock, _, _, _, viewMock) = createSut(
            hasFileDownloadError: true
        )
        
        let indexPath = Copy.fileIndexPath
        sut.onCellAccessoryTap(at: indexPath)
        
        _ = await taskLauncherMock.launchTasks.last?.result
        
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.map (\.loadingState), [.loading, .notLoaded])
        XCTAssertEqual(folderContentMock.setLoadingStateAtPathCalls.map(\.path), Array(repeating: Copy.file.path, count: 2))
        
        XCTAssertEqual(viewMock.updateAccessoryViewForRowsAtIndexPathsCalls, [[indexPath], [indexPath]])
    }
    
    // MARK: shouldHighlightRow(at:)
    
    func testShouldHighlightRow_isFolder_trueReturned() {
        let (sut, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = createSut(
            hasFileDownloadError: true
        )
        
        let result = sut.shouldHighlightRow(at: Copy.folderIndexPath)
        
        XCTAssertTrue(result)
    }
    
    func testShouldHighlightRow_isLoadedFile_trueReturned() {
        let (sut, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = createSut(
            fileLoadingState: .loaded
        )
        
        let result = sut.shouldHighlightRow(at: Copy.fileIndexPath)
        
        XCTAssertTrue(result)
    }
    
    func testShouldHighlightRow_isNotLoadedFile_falseReturned() {
        for loadingState: LoadingState in [.notLoaded, .loading] {
            let (sut, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = createSut(
                fileLoadingState: loadingState
            )
            
            let result = sut.shouldHighlightRow(at: Copy.fileIndexPath)
            
            XCTAssertFalse(result)
        }
    }
    
    // MARK: willDisplayCell(at:)
    
    func testWillDisplayCell_last_nextContentPageLoadingStarted() {
        let (sut, _, _, _, _, _, _, contentPaginatorMock, _, _, _, _, _, _, _) = createSut()
        
        let indexPath = Copy.lastEntryIndexPath
        
        sut.willDisplayCell(at: indexPath)
        
        XCTAssertEqual(contentPaginatorMock.loadMoreCallCount, 1)
    }
    
    func testWillDisplayCell_notLast_nextContentPageLoadingNotStarted() {
        let (sut, _, _, _, _, _, _, contentPaginatorMock, _, _, _, _, _, _, _) = createSut()
        
        let indexPath = prevIndexPath(Copy.lastEntryIndexPath)
        
        sut.willDisplayCell(at: indexPath)
        
        XCTAssertEqual(contentPaginatorMock.loadMoreCallCount, 0)
    }
    
    // MARK: loadNextPage()
    
    func testLoadNextPage_success_nextPageFromSequenceRetrieved() async throws {
        let (sut, _, _, _, _, _, pageIteratorMock, _, _, _, _, _, _, _, _) = createSut()
        
        sut.onViewLoaded()
        let entries = try await sut.loadNextPage()
        
        XCTAssertEqual(pageIteratorMock.nextCallCount, 1)
        XCTAssertEqual(entries, Copy.entries)
    }
    
    func testLoadNextPage_fetchNextPageError_errorReturned() async throws {
        let (sut, _, _, _, _, _, pageIteratorMock, _, _, _, _, _, _, _, _) = createSut(
            hasFetchNextPageError: true
        )
        
        sut.onViewLoaded()
        
        await assertThrowsAsyncError(
            try await sut.loadNextPage()
        ) { error in
            XCTAssertEqual(error as NSError, Copy.fetchContentNextPageError)
        }
        
        XCTAssertEqual(pageIteratorMock.nextCallCount, 1)
    }
    
    // MARK: didFinishLoadingNewPage(with:)
    
    func testDidFinishLoadingNewPage_success_entriesAppended() {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, _, _, _, _, _) = createSut()
        let entries = Copy.entries
        
        sut.didFinishLoadingNewPage(with: .success(entries))
        
        XCTAssertEqual(folderContentMock.appendEntriesCalls.count, 1)
        XCTAssertEqual(folderContentMock.appendEntriesCalls.last, entries)
    }
    
    func testDidFinishLoadingNewPage_firstPageSuccess_viewDataReloaded() {
        let (sut, folderContentMock, _, _, _, _, _, _, _, _, _, _, _, _, viewMock) = createSut()
        folderContentMock.numberOfEntriesResult = 0
        
        let entries = Copy.entries
        
        sut.didFinishLoadingNewPage(with: .success(entries))
        
        XCTAssertEqual(viewMock.reloadDataCallCount, 1)
        XCTAssertEqual(viewMock.insertRowsCalls.count, 0)
    }
    
    func testDidFinishLoadingNewPage_nextPageSuccess_newCellsAppended() {
        let (sut, _, _, _, _, _, _, _, _, _, _, _, _, _, viewMock) = createSut()
        
        let entries = Copy.entries
        
        sut.didFinishLoadingNewPage(with: .success(entries))
        
        XCTAssertEqual(viewMock.reloadDataCallCount, 0)
        XCTAssertEqual(viewMock.insertRowsCalls.count, 1)
        XCTAssertEqual(viewMock.insertRowsCalls.last?.indexPath, Copy.afterLastEntryIndexPath)
        XCTAssertEqual(viewMock.insertRowsCalls.last?.count, entries.count)
    }
    
    func testDidFinishLoadingNewPage_failure_alertMessageShown() {
        let (sut, _, _, _, _, _, _, _, _, _, _, alertBuilderFactoryMock, alertBuilderMock, alertMock, viewMock) = createSut()
        
        sut.didFinishLoadingNewPage(with: .failure(NSError.mock))
        
        XCTAssertEqual(alertBuilderFactoryMock.createAlertBuilderCallCount, 1)
        XCTAssertEqual(alertBuilderMock.setMessageCalls, [Copy.loadingFolderFailedErrorMessage])
        XCTAssertEqual(alertBuilderMock.buildCallCount, 1)

        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.count, 1)
        XCTAssertIdentical(alertMock.showOnNodeAnimatedCalls.last?.node as? NodeMock, viewMock.node as? NodeMock)
        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.last?.animated, true)
    }
    
    // MARK: Helper methods
    
    private func createSut(
        fileLoadingState: LoadingState = .notLoaded,
        userRealNotificationSubject: Bool = false,
        hasSyncLoadingStatesError: Bool = false,
        hasFileDownloadError: Bool = false,
        hasFetchNextPageError: Bool = false
    ) -> (
        FileBrowserControllerImpl,
        FolderContentMock,
        FileBrowserNavigatorMock,
        BucketRepositoryFactoryMock,
        BucketRepositoryMock,
        ContentPageSequenceMock,
        ContentPageSequenceIteratorMock,
        FolderContentPaginatorMock,
        NotificationSubject,
        MainActorRunnerMock,
        TaskLauncherMock,
        AlertBuilderFactoryMock,
        AlertBuilderMock,
        AlertMock,
        FileBrowserViewMock
    ) {
        let folderContentMock = FolderContentMock()
        folderContentMock.numberOfEntriesResult = Copy.entries.count
        folderContentMock.entryAtIndexClosure = {
            Copy.entries[$0].copy(
                loadingState: fileLoadingState
            )
        }
        
        if hasSyncLoadingStatesError {
            folderContentMock.syncLoadingStatesError = Copy.loadingStatesError
        }
        
        let navigatorMock = FileBrowserNavigatorMock()
        
        let contentPageIteratorMock = ContentPageSequenceIteratorMock()
        if hasFetchNextPageError {
            contentPageIteratorMock.nextError = Copy.fetchContentNextPageError
        } else {
            contentPageIteratorMock.nextResult = Copy.entries
        }
        
        var contentPageSequenceMock = ContentPageSequenceMock()
        contentPageSequenceMock.makeAsyncIteratorResult = contentPageIteratorMock
        
        let repositoryMock = BucketRepositoryMock()
        repositoryMock.getContentWithPathResult = AnyAsyncSequence(
            sequence: &contentPageSequenceMock
        )
        if hasFileDownloadError {
            repositoryMock.downloadFileWithPathError = Copy.fileDownloadError
        } else {
            repositoryMock.downloadFileWithPathResult = Copy.file
                .copy(loadingState: .loaded)
        }
        
        let repositoryFactoryMock = BucketRepositoryFactoryMock()
        repositoryFactoryMock.createBucketRepositoryResult = repositoryMock
        
        let folderContentPaginatorMock = FolderContentPaginatorMock()
        let notificationSubject: NotificationSubject = userRealNotificationSubject
            ? NotificationSubjectImpl(
                notificationCenter: NotificationCenter()
            )
            : {
                let result = NotificationSubjectMock()
                result.subscribeNameObjectOnEventResult = CancelllableMock()
                return result
            }()
        let mainActorRunnerMock = MainActorRunnerMock()
        let taskLauncherMock = TaskLauncherMock()
        
        let alertMock = AlertMock()
        
        let alertBuilderMock = AlertBuilderMock()
        alertBuilderMock.buildResult = alertMock
        
        let alertBuilderFactoryMock = AlertBuilderFactoryMock()
        alertBuilderFactoryMock.createAlertBuilderResult = alertBuilderMock
        
        let viewMock = FileBrowserViewMock()
        viewMock.nodeResult = NodeMock()
        
        let sut = FileBrowserControllerImpl(
            path: Copy.path,
            folderContent: folderContentMock,
            navigator: navigatorMock,
            repositoryFactory: repositoryFactoryMock,
            contentPaginator: folderContentPaginatorMock,
            notificationSubject: notificationSubject,
            mainActorRunner: mainActorRunnerMock,
            taskLauncher: taskLauncherMock,
            alertBuilderFactory: alertBuilderFactoryMock
        )        
        sut.view = viewMock
        
        return (
            sut,
            folderContentMock,
            navigatorMock,
            repositoryFactoryMock,
            repositoryMock,
            contentPageSequenceMock,
            contentPageIteratorMock,
            folderContentPaginatorMock,
            notificationSubject,
            mainActorRunnerMock,
            taskLauncherMock,
            alertBuilderFactoryMock,
            alertBuilderMock,
            alertMock,
            viewMock
        )
    }
    
    private func prevIndexPath(_ indexPath: IndexPath) -> IndexPath {
        IndexPath(
            row: indexPath.row - 1,
            section: indexPath.section
        )
    }
    
    typealias ContentPageSequenceMock = AsyncSequenceMock<[Entry]>
    typealias ContentPageSequenceIteratorMock = AsyncSequenceIteratorMock<[Entry]>
    
    private enum Copy {
        static let path = "folder1/folder2"
        
        static let willEnterBackgroundNotificationName = "UIApplicationWillEnterForegroundNotification"
        
        static let entries = [Entry].mock
        
        static let loadingStatesError = NSError(domain: "loadingStatesError", code: 1)
        static let fileDownloadError = NSError(domain: "fileDownloadError", code: 2)
        static let fetchContentNextPageError = NSError(domain: "fetchContentNextPageError", code: 3)
        
        static let fileIndexPath = IndexPath(row: 0, section: 0)
        static let folderIndexPath = IndexPath(row: 1, section: 0)
        
        static let file = entries[0]
        static let folder = entries[1]
        
        static let lastEntryIndexPath = IndexPath(
            row: entries.count - 1, 
            section: 0
        )
        static let afterLastEntryIndexPath = IndexPath(
            row: entries.count,
            section: 0
        )
        static let loadingFolderFailedErrorMessage = "Loading folder content failed"
    }
}

