//
//  NotificationSubjectTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class NotificationSubjectTests: XCTestCase {
    
    // MARK: subscribe(name:)
    
    func testSubscribeForName_called_subscribesForNameWithNilObject() async throws {
        let sut = createSut()
                
        _ = sut.subscribe(name: Copy.noteName)
        
        XCTAssertEqual(sut.subscribeNameObjectCalls.count, 1)
        XCTAssertEqual(sut.subscribeNameObjectCalls.last?.name, Copy.noteName)
        XCTAssertNil(sut.subscribeNameObjectCalls.last?.object)
    }
    
    func testSubscribeForName_called_returnedSequenceMatches() async throws {
        let sut = createSut()
                
        let result = sut.subscribe(name: Copy.noteName)

        XCTAssertEqual(result.id, Copy.sequence.id)
    }
    
    // MARK: subscribe(name:, onEvent:)
    
    func testSubscribeForNameOnEvent_called_subscribesForNameWithNilObject() async throws {
        let sut = createSut()
                
        _ = sut.subscribe(name: Copy.noteName) { _ in }
        
        XCTAssertEqual(sut.subscribeNameObjectOnEventCalls.count, 1)
        XCTAssertEqual(sut.subscribeNameObjectOnEventCalls.last?.name, Copy.noteName)
        XCTAssertNil(sut.subscribeNameObjectOnEventCalls.last?.object)
    }
    
    func testSubscribeForNameOnEvent_called_onEventCallbackMatches() async throws {
        let sut = createSut()
                
        var callbackCalled = false
        _ = sut.subscribe(name: Copy.noteName) { _ in
            callbackCalled = true
        }

        let callback = sut.subscribeNameObjectOnEventCalls.last?.onEvent
        callback?(Copy.testNotification)
        
        XCTAssertTrue(callbackCalled)
    }
    
    func testSubscribeForNameOnEvent_called_resultCancellableMatches() async throws {
        let sut = createSut()
                
        let result = sut.subscribe(name: Copy.noteName) { _ in }
        
        XCTAssertIdentical(sut.subscribeNameObjectOnEventResult as? CancelllableMock, Copy.cancelable)
        XCTAssertIdentical(result as? CancelllableMock, Copy.cancelable)
    }
    
    // MARK: send(name:)
    
    func testSendWithName_called_sendsWithNilObjectAndNilUserInfo() async throws {
        let sut = createSut()
        
        sut.send(name: Copy.noteName)
        
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.count, 1)
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.last?.name, Copy.noteName)
        XCTAssertNil(sut.sendNameObjectUserInfoCalls.last?.object)
        XCTAssertNil(sut.sendNameObjectUserInfoCalls.last?.userInfo)
    }
    
    // MARK: send(name:, object:)
    
    func testSendWithNameObject_called_sendsWithNilUserInfo() async throws {
        let sut = createSut()
        
        sut.send(name: Copy.noteName, object: Copy.noteObject)
        
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.count, 1)
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.last?.name, Copy.noteName)
        XCTAssertIdentical(sut.sendNameObjectUserInfoCalls.last?.object, Copy.noteObject)
        XCTAssertNil(sut.sendNameObjectUserInfoCalls.last?.userInfo)
    }
    
    // MARK: send(name:, userInfo:)
    
    func testSendWithNameUserInfo_called_sendsWithNilObject() async throws {
        let sut = createSut()
        
        sut.send(name: Copy.noteName, userInfo: Copy.noteUserInfo)
        
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.count, 1)
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.last?.name, Copy.noteName)
        XCTAssertNil(sut.sendNameObjectUserInfoCalls.last?.object)
        XCTAssertEqual(sut.sendNameObjectUserInfoCalls.last?.userInfo as? [String : Int], Copy.noteUserInfo)
    }
    
    // MARK: Helper methods
    
    private func createSut() -> NotificationSubjectMock {
        let sut = NotificationSubjectMock()
        
        sut.subscribeNameObjectReturn = Copy.sequence
        sut.subscribeNameObjectOnEventResult = Copy.cancelable
        
        return sut
    }
    
    private enum Copy {
        static let noteName = "noteName"
        static let noteObject = NSObject()
        static let noteUserInfo = [
            "testKey": 132
        ]
        static let testId = "testId"
        static let sequence = {
            var sequence = ArrayAsyncSequence(array: [Notification]())
            return AnyAsyncSequence(
                sequence: &sequence,
                id: testId
            )
        }()
        static let cancelable = CancelllableMock()
        static let testNotification = Notification(
            name: Notification.Name(noteName),
            object: noteObject,
            userInfo: noteUserInfo
        )
    }
}
