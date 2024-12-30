//
//  RecursiveLockSyncPerformerImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct RecursiveLockSyncPerformerImpl: SyncPerformer {
    init(lock: NSRecursiveLock = NSRecursiveLock()) {
        self.lock = lock
    }
    private let lock: NSRecursiveLock
    
    func sync<T>(_ closure: () throws -> T) rethrows -> T {
        try lock.withLock {
            try closure()
        }
    }
}

struct RecursiveLockSyncPerformerFactoryImpl: SyncPerformerFactory {
    func createSyncPerformer() -> any SyncPerformer {
        RecursiveLockSyncPerformerImpl()
    }
}
