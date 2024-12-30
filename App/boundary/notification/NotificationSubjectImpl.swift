//
//  NotificationSubjectImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class NotificationSubjectImpl: NotificationSubject {
    init(
        notificationCenter: NotificationCenter = NotificationCenter.default
    ) {
        self.notificationCenter = notificationCenter
    }
    
    private let notificationCenter: NotificationCenter
    
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
            notificationCenter: notificationCenter,
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
