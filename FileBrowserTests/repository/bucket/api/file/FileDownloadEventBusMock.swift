//
//  FileDownloadEventBusMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileDownloadEventBusMock: FileDownloadEventBus {
    
    private(set) var subscribeParentPathOnEventCalls: [(
        parentPath: String,
        onEvent: (String, Error?) -> Void
    )] = []
    
    var subscribeParentPathOnEventResult: Cancellable! = CancelllableMock()
    func subscribe(
        parentPath: String,
        onEvent: @escaping (String, Error?) -> Void
    ) -> Cancellable {
        subscribeParentPathOnEventCalls.append((
            parentPath: parentPath,
            onEvent: onEvent
        ))
        
        return subscribeParentPathOnEventResult
    }
    
    private(set) var sendForPathWithErrorCalls: [(
        path: String,
        error: Error?
    )] = []
    
    func send(path: String, error: Error?) {
        sendForPathWithErrorCalls.append((
            path: path,
            error: error
        ))        
    }
}
