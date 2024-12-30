//
//  NotificationSubjectImplTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class NotificationSubjectImplTests: XCTestCase {
    
    // MARK: subscribe(name:, object:, onEvent:)
        
    func testSubscribeNameObjectOnEvent_subscribedToObjectAndSentToSameObject_received() async throws {
        try await when(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: Copy.testObject,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObjectOnEvent_subscribedToObjectAndSentToAny_notReceived() async throws {
        try await when(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
        
    func testSubscribeNameObjectOnEvent_subscribedToObjectAndSentToDifferentObject_notReceived() async throws {
        try await when(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: Copy.testObject2,
            assertThatEventShouldBeReceived: false
        )
    }
    
    func testSubscribeNameObjectOnEvent_subscribedToAnyAndSentToAny_received() async throws {
        try await when(
            subscribedObject: nil,
            isSent: true,
            sentObject: nil,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObjectOnEvent_subscribedToAnyAndSentToSomeObject_received() async throws {
        try await when(
            subscribedObject: nil,
            isSent: true,
            sentObject: Copy.testObject,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObjectOnEvent_subscribedToAnyAndNoEventSent_notReceived() async throws {
        try await when(
            subscribedObject: nil,
            isSent: false,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
    
    func testSubscribeNameObjectOnEvent_subscribedToObjectAndNoEventSent_notReceived() async throws {
        try await when(
            subscribedObject: Copy.testObject,
            isSent: false,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
    
    // MARK: subscribe(name:, object:)
    
    func testSubscribeNameObject_subscribedToObjectAndSentToSameObject_received() async throws {
        try await when2(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: Copy.testObject,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObject_subscribedToObjectAndSentToAny_notReceived() async throws {
        try await when2(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
        
    func testSubscribeNameObject_subscribedToObjectAndSentToDifferentObject_notReceived() async throws {
        try await when2(
            subscribedObject: Copy.testObject,
            isSent: true,
            sentObject: Copy.testObject2,
            assertThatEventShouldBeReceived: false
        )
    }
    
    func testSubscribeNameObject_subscribedToAnyAndSentToAny_received() async throws {
        try await when2(
            subscribedObject: nil,
            isSent: true,
            sentObject: nil,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObject_subscribedToAnyAndSentToSomeObject_received() async throws {
        try await when2(
            subscribedObject: nil,
            isSent: true,
            sentObject: Copy.testObject,
            assertThatEventShouldBeReceived: true
        )
    }
    
    func testSubscribeNameObject_subscribedToAnyAndNoEventSent_notReceived() async throws {
        try await when2(
            subscribedObject: nil,
            isSent: false,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
    
    func testSubscribeNameObject_subscribedToObjectAndNoEventSent_notReceived() async throws {
        try await when2(
            subscribedObject: Copy.testObject,
            isSent: false,
            sentObject: nil,
            assertThatEventShouldBeReceived: false
        )
    }
    
    // MARK: Helper methods
    
    private func createSut() -> NotificationSubjectImpl {
        NotificationSubjectImpl(
            notificationCenter: NotificationCenter()
        )
    }
    
    private func when(
        subscribedObject: AnyObject?,
        isSent: Bool,
        sentObject: AnyObject?,
        assertThatEventShouldBeReceived: Bool,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await when(
            subscribedObject: subscribedObject,
            isSent: isSent,
            sentObject: sentObject,
            assertThatEventShouldBeReceived: assertThatEventShouldBeReceived,
            subscriptionFactory: { sut, subscribedObject, expectation in
                sut.subscribe(
                    name: Copy.testName,
                    object: subscribedObject
                ) { notification in
                    defer { expectation.fulfill() }
                    
                    XCTAssertEqual(notification.name.rawValue, Copy.testName)
                    
                    guard let subscribedObject else { return }
                    
                    if let notificationObject = notification.object as? AnyObject {
                        XCTAssertIdentical(notificationObject, subscribedObject)
                    } else {
                        XCTAssertNil(notification.object)
                    }
                }
            },
            filePath: filePath,
            line: line
        )
    }
    
    private func when2(
        subscribedObject: AnyObject?,
        isSent: Bool,
        sentObject: AnyObject?,
        assertThatEventShouldBeReceived: Bool,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await when(
            subscribedObject: subscribedObject,
            isSent: isSent,
            sentObject: sentObject,
            assertThatEventShouldBeReceived: assertThatEventShouldBeReceived,
            subscriptionFactory: { sut, subscribedObject, expectation in
                let sequence = sut.subscribe(
                    name: Copy.testName,
                    object: subscribedObject
                )
                
                return AnyTaskCancellable (
                    Task {
                        var iterator = sequence.makeAsyncIterator()
                        
                        guard let notification = try await iterator.next()  else {
                            XCTAssertFalse(assertThatEventShouldBeReceived)
                            
                            return
                        }

                        defer { expectation.fulfill() }
                        
                        XCTAssertEqual(notification.name.rawValue, Copy.testName)
                        
                        guard let subscribedObject else { return }
                        
                        if let notificationObject = notification.object as? AnyObject {
                            XCTAssertIdentical(notificationObject, subscribedObject)
                        } else {
                            XCTAssertNil(notification.object)
                        }
                    }
                )
            },
            filePath: filePath,
            line: line
        )
    }
    
    private func when(
        subscribedObject: AnyObject?,
        isSent: Bool,
        sentObject: AnyObject?,
        assertThatEventShouldBeReceived: Bool,
        subscriptionFactory: (NotificationSubjectImpl, AnyObject?, XCTestExpectation) -> Cancellable,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let sut = createSut()
        
        let expectation = expectation(description: Copy.expectationName)
        expectation.isInverted = !assertThatEventShouldBeReceived
        
        let cancellable = subscriptionFactory(sut, subscribedObject, expectation)
        
        if isSent {
            sut.send(
                name: Copy.testName,
                object: sentObject,
                userInfo: nil
            )
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        cancellable.cancel()
    }
    
    private enum Copy {
        static let testName = "testNotificationName"
        static let testObject = NSObject()
        static let testObject2 = NSObject()
        static let expectationName = "NotificationReceived"
    }
    
    private struct AnyTaskCancellable: Cancellable {
        init(_ task: Task<some Any, some Error>) {
            _cancel = task.cancel
        }
        
        private let _cancel: () -> Void
        
        func cancel() {
            _cancel()
        }
    }
}
