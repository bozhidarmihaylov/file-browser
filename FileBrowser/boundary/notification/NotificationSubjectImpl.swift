//
//  NotificationSubjectImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class NotificationSubjectImpl: NotificationSubject {
    private var notificationCenter: NotificationCenter { NotificationCenter.default }
    
    func subscribe(
        name: String,
        object: AnyObject?
    ) -> AnyAsyncSequence<Notification> {
        var sequence = notificationCenter.notifications(
            named: Notification.Name(name),
            object: object
        )
        return AnyAsyncSequence(sequence: &sequence)
    }
    
    func subscribe(
        name: String,
        object: AnyObject?,
        onEvent: @escaping (Notification) -> Void
    ) -> Cancellable {
        NotificationSubscriptionImpl(
            name: name,
            object: object,
            onEvent: onEvent
        )
    }
    
    func send(
        name: String,
        object: AnyObject?,
        userInfo: [AnyHashable: Any]?
    ) {
        notificationCenter.post(
            name: Notification.Name(name),
            object: object,
            userInfo: userInfo
        )
    }
}

final class NotificationSubscriptionImpl: Cancellable {
    deinit {
        cancel()
    }
    
    init(
        name: String,
        object: AnyObject?,
        onEvent: @escaping (Notification) -> Void
    ) {
        self.name = name
        self.object = object
        self.onEvent = onEvent
        
        start()
    }

    private let name: String
    private let object: AnyObject?
    private let onEvent: (Notification) -> Void
    
    private var notificationCenter: NotificationCenter { NotificationCenter.default }
    
    @objc private func onEvent(_ notification: Notification) {
        onEvent(notification)
    }
    
    private func start() {
        notificationCenter.addObserver(
            self,
            selector: #selector(onEvent(_ :)),
            name: Notification.Name(name),
            object: object
        )
    }
    
    func cancel() {
        notificationCenter.removeObserver(self)
    }
}
