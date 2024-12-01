//
//  NotificationSubject.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol NotificationSubject {
    func subscribe(
        name: String,
        object: AnyObject?
    ) -> AnyAsyncSequence<Notification>
    
    func subscribe(
        name: String,
        object: AnyObject?,
        onEvent: @escaping (Notification) -> Void
    ) -> Cancellable
    
    func send(
        name: String,
        object: AnyObject?,
        userInfo: [AnyHashable: Any]?
    )
}

extension NotificationSubject {
    func subscribe(
        name: String
    ) -> AnyAsyncSequence<Notification> {
        subscribe(name: name, object: nil)
    }
    
    func subscribe(
        name: String, 
        onEvent: @escaping (Notification) -> Void
    ) -> Cancellable {
        subscribe(name: name, object: nil, onEvent: onEvent)
    }
    
    func send(
        name: String
    ) {
        send(name: name, object: nil, userInfo: nil)
    }

    func send(
        name: String,
        object: AnyObject?
    ) {
        send(name: name, object: object, userInfo: nil)
    }
}
