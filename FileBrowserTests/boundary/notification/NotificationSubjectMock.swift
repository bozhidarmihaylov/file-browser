//
//  NotificationSubjectMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class NotificationSubjectMock: NotificationSubject {
    func subscribe(name: String, object: AnyObject?) -> AnyAsyncSequence<Notification> {
        var sequence = ArraySequence(array: [Notification]())
        return AnyAsyncSequence(sequence: &sequence)
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
    
    func send(name: String, object: AnyObject?, userInfo: [AnyHashable : Any]?) {
        
    }
}
