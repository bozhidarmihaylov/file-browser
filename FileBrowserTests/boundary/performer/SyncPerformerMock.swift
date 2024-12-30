//
//  SyncPerformerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SyncPerformerMock: SyncPerformer {
    func sync<T>(_ closure: () throws -> T) rethrows -> T {
        try closure()
    }
}
