//
//  NotificationSubjectMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class NotificationSubjectMock: NotificationSubject {
    
    private(set) var subscribeNameObjectCalls: [(
        name: String,
        object: AnyObject?
    )] = []

    var subscribeNameObjectReturn: AnyAsyncSequence<Notification>! = nil
    func subscribe(name: String, object: AnyObject?) -> AnyAsyncSequence<Notification> {
        subscribeNameObjectCalls.append((
            name: name,
            object: object
        ))
        
        return subscribeNameObjectReturn
    }
    
    private(set) var subscribeNameObjectOnEventCalls: [(
        name: String,
        object: AnyObject?,
        onEvent: (Notification) -> Void
    )] = []
    
    var subscribeNameObjectOnEventResult: Cancellable! = nil
    func subscribe(name: String, object: AnyObject?, onEvent: @escaping (Notification) -> Void) -> Cancellable {
        subscribeNameObjectOnEventCalls.append((name, object, onEvent))
        
        return subscribeNameObjectOnEventResult
    }
    
    private(set) var sendNameObjectUserInfoCalls: [(
        name: String,
        object: AnyObject?,
        userInfo: [AnyHashable: Any]?
    )] = []
    
    var onSendNameObjectUserInfoCalled: ((String, AnyObject?, [AnyHashable: Any]?) -> Void)? = nil
    func send(name: String, object: AnyObject?, userInfo: [AnyHashable : Any]?) {
        sendNameObjectUserInfoCalls.append((name, object, userInfo))
        
        onSendNameObjectUserInfoCalled?(name, object, userInfo)
    }
}
