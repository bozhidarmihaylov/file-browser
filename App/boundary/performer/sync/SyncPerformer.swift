//
//  SyncPerformer.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol SyncPerformer {
    func sync<T>(_ closure: () throws -> T) rethrows -> T
}

protocol SyncPerformerFactory {
    func createSyncPerformer() -> SyncPerformer
}
