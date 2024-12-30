//
//  FileBrowserControllerTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileBrowserControllerTests: XCTestCase {
    func testOnInit_called_subsribesToWillEnterForegroundNotification() throws {
        let (sut, _, _, _, _, noteSubjectMock, _, _) = createSut()

        noteSubjectMock.subscribeNameObjectOnEventResult = CancelllableMock()
        sut.onInit()
        
        XCTAssertEqual(noteSubjectMock.subscribeNameObjectOnEventCalls.count, 1)
        XCTAssertEqual(noteSubjectMock.subscribeNameObjectOnEventCalls.last?.name,
                       Copy.willEnterBackgroundNotificationName)
        XCTAssertNil(noteSubjectMock.subscribeNameObjectOnEventCalls.last?.object)
    }
    
    func testOnInit_willEnterForegroundNotificationSent_received() throws {
        let (sut, _, _, _, _, noteSubjectMock, _, _) = createSut()

        noteSubjectMock.subscribeNameObjectOnEventResult = CancelllableMock()
        sut.onInit()
        
        XCTAssertEqual(noteSubjectMock.subscribeNameObjectOnEventCalls.count, 1)
        XCTAssertEqual(noteSubjectMock.subscribeNameObjectOnEventCalls.last?.name,
                       Copy.willEnterBackgroundNotificationName)
        XCTAssertNil(noteSubjectMock.subscribeNameObjectOnEventCalls.last?.object)
    }
    
    
    // MARK: Helper methods
    
    private enum Copy {
        static let willEnterBackgroundNotificationName = "UIApplicationWillEnterForegroundNotification"
    }

    private func createSut(
        path: String = ""
    ) -> (
        FileBrowserController,
        FileBrowserNavigatorMock,
        FileBrowserCellVmFactoryMock,
        BucketRepositoryFactoryMock,
        FileSystemMock,
        NotificationSubjectMock,
        LoadingStateSyncerMock,
        MainActorRunnerMock
    ) {
        let navigatorMock = FileBrowserNavigatorMock()
        let cellVmFactoryMock = FileBrowserCellVmFactoryMock()
        let repositoryFactoryMock = BucketRepositoryFactoryMock()
        let fileSystemMock = FileSystemMock()
        let notificationSubjectMock = NotificationSubjectMock()
        let loadingStateSyncerMock = LoadingStateSyncerMock()
        let mainActorRunnerMock = MainActorRunnerMock()
        
        let sut = FileBrowserControllerImpl(
            path: path,
            navigator: navigatorMock,
            cellVmFactory: cellVmFactoryMock,
            repositoryFactory: repositoryFactoryMock,
            notificationSubject: notificationSubjectMock,
            loadingStateSyncer: loadingStateSyncerMock,
            mainActorRunner: mainActorRunnerMock
        )
        
        return (
            sut,
            navigatorMock,
            cellVmFactoryMock,
            repositoryFactoryMock,
            fileSystemMock,
            notificationSubjectMock,
            loadingStateSyncerMock,
            mainActorRunnerMock
        )
    }
}

