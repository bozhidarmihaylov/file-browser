//
//  FileDownloadEventBusImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class FileDownloadEventBusImplTests: XCTestCase {
    // MARK: subscribe(parentPath:, onEvent:)
    
    func testSubscribe_called_notificationSubjectSubscribed() {
        let (sut, notificationSubjectMock, cancellableMock) = createSut()
        
        let result = sut.subscribe(parentPath: Copy.parentPath) { _, _ in }
        
        XCTAssertEqual(notificationSubjectMock.subscribeNameObjectOnEventCalls.count, 1)
        XCTAssertEqual(notificationSubjectMock.subscribeNameObjectOnEventCalls.last?.name, Copy.notificationName)
        XCTAssertNil(notificationSubjectMock.subscribeNameObjectOnEventCalls.last?.object)
        XCTAssertIdentical(result as AnyObject, cancellableMock)
    }
    
    func testSubscribe_called_filePathPassedToOnEvent() {
        for hasError in [false, true] {
            let (sut, notificationSubjectMock, _) = createSut()
            
            _ = sut.subscribe(parentPath: Copy.parentPath) { path, error in
                XCTAssertEqual(path, Copy.filePath)
            }
            
            let onEvent = notificationSubjectMock.subscribeNameObjectOnEventCalls.last?.onEvent
            
            onEvent?(hasError ? Copy.errorNotification : Copy.noErrorNotification)
        }
    }
    
    func testSubscribe_noError_noErrorPassedToOnEvent() {
        let (sut, notificationSubjectMock, _) = createSut()
        
        _ = sut.subscribe(parentPath: Copy.parentPath) { path, error in
            XCTAssertNil(error)
        }
        
        let onEvent = notificationSubjectMock.subscribeNameObjectOnEventCalls.last?.onEvent
        
        onEvent?(Copy.noErrorNotification)
    }
    
    func testSubscribe_error_errorPassedToOnEvent() {
        let (sut, notificationSubjectMock, _) = createSut()
        
        _ = sut.subscribe(parentPath: Copy.parentPath) { path, error in
            XCTAssertEqual(error as? NSError, Copy.error)
        }
        
        let onEvent = notificationSubjectMock.subscribeNameObjectOnEventCalls.last?.onEvent
        
        onEvent?(Copy.errorNotification)
    }
    
    // MARK: send(path:, error:)
    
    func testSend_called_notificationForParentSent() {
        for hasError in [false, true] {
            let (sut, notificationSubjectMock, _) = createSut()
            
            sut.send(
                path: Copy.filePath,
                error: hasError ? Copy.error : nil
            )
            
            XCTAssertEqual(notificationSubjectMock.sendNameObjectUserInfoCalls.count, 1)
            XCTAssertEqual(notificationSubjectMock.sendNameObjectUserInfoCalls.last?.name, Copy.notificationName)
            XCTAssertNil(notificationSubjectMock.sendNameObjectUserInfoCalls.last?.object)
            XCTAssertEqual(notificationSubjectMock.sendNameObjectUserInfoCalls.last?.userInfo?[Copy.filePathKey] as? String, Copy.filePath)
        }
    }
    
    func testSend_noError_noErrorPassetToSubjectSend() {
        let (sut, notificationSubjectMock, _) = createSut()
        
        sut.send(
            path: Copy.filePath,
            error: nil
        )
        
        XCTAssertNil(notificationSubjectMock.sendNameObjectUserInfoCalls.last?.userInfo?[Copy.downloadErrorKey])
    }

    func testSend_error_errorPassedToSubjectSend() {
        let (sut, notificationSubjectMock, _) = createSut()
        
        sut.send(
            path: Copy.filePath,
            error: Copy.error
        )
        
        XCTAssertEqual(notificationSubjectMock.sendNameObjectUserInfoCalls.last?.userInfo?[Copy.downloadErrorKey] as? NSError, Copy.error)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> (
        FileDownloadEventBusImpl,
        NotificationSubjectMock,
        CancelllableMock
    ) {
        let cancellableMock = CancelllableMock()
        let notificationSubjectMock = NotificationSubjectMock()
        notificationSubjectMock.subscribeNameObjectOnEventResult = cancellableMock
        
        let sut = FileDownloadEventBusImpl(
            notificationSubject: notificationSubjectMock
        )
        
        return (
            sut,
            notificationSubjectMock,
            cancellableMock
        )
    }
    
    private enum Copy {
        static let filePath = "folder1/file.ext"
        static let parentPath = "folder1"
        static let notificationName = "Complete_download_in_folder1"
        
        static let error = NSError.mock
        
        static let userInfo: [String: Any] = [
            filePathKey: filePath
        ]
        
        static let errorUserInfo: [String: Any] = [
            filePathKey: filePath,
            downloadErrorKey: error
        ]
        
        static let noErrorNotification = Notification(
            name: Notification.Name(notificationName),
            object: nil,
            userInfo: userInfo
        )
        
        static let errorNotification = Notification(
            name: Notification.Name(notificationName),
            object: nil,
            userInfo: errorUserInfo
        )
        
        static let filePathKey = "DownloadedFilePath"
        static let downloadErrorKey = "DownloadError"
    }
}
