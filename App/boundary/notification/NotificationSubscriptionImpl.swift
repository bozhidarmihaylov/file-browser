//
//  NotificationSubscriptionImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class NotificationSubscriptionImpl: Cancellable {
    deinit {
        cancel()
    }
    
    init(
        name: String,
        object: AnyObject?,
        notificationCenter: NotificationCenter = .default,
        onEvent: @escaping (Notification) -> Void
    ) {
        self.name = name
        self.object = object
        self.notificationCenter = notificationCenter
        self.onEvent = onEvent
        
        start()
    }

    private let name: String
    private let object: AnyObject?
    private let notificationCenter: NotificationCenter
    private let onEvent: (Notification) -> Void
    
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
