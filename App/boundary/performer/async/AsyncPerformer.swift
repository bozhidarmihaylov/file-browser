//
//  AsyncPerformer.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol AsyncPerformer {
    func async<T>(_ closure: () async throws -> T) async rethrows -> T
}

protocol AsyncPerformerFactory {
    func createAsyncPerformer() -> AsyncPerformer
}
