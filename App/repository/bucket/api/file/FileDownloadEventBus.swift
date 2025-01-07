//
//  FileDownloadEventBus.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileDownloadEventBus {
    func subscribe(
        parentPath: String,
        onEvent: @escaping (String, Error?) -> Void
    ) -> Cancellable
    
    func send(path: String, error: Error?)
}

struct FileDownloadEventBusImpl: FileDownloadEventBus {
    init(
        notificationSubject: NotificationSubject = NotificationSubjectImpl()
    ) {
        self.notificationSubject = notificationSubject
    }
    
    private let notificationSubject: NotificationSubject
    
    func subscribe(
        parentPath: String,
        onEvent: @escaping (String, Error?) -> Void
    ) -> Cancellable {
        notificationSubject.subscribe(
            name: notificationName(for: parentPath)
        ) { notification in
            let path = notification.userInfo?[Copy.filePathKey] as? String
            
            guard let path else {
                return
            }
            
            let error = notification.userInfo?[Copy.downloadErrorKey] as? Error
            
            onEvent(path, error)
        }
    }
    
    func send(path: String, error: Error?) {
        let parentPath = path
            .split(separator: "/")
            .dropLast()
            .joined(separator: "/")
        
        let name = notificationName(for: parentPath)
        
        var userInfo: [String: Any] = [
            Copy.filePathKey: path
        ]

        if let error {
            userInfo[Copy.downloadErrorKey] = error
        }
        
        notificationSubject.send(
            name: name,
            object: nil,
            userInfo: userInfo
        )
    }
    
    private func notificationName(for parentPath: String) -> String {
        "Complete_download_in_\(parentPath)"
    }
    
    private enum Copy {
        static let filePathKey = "DownloadedFilePath"
        static let downloadErrorKey = "DownloadError"
    }
}
