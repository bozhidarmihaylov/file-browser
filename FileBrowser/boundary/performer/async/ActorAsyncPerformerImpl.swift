//
//  ActorAsyncPerformerImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final actor ActorAsyncPerformerImpl: AsyncPerformer {
    func async<T>(_ closure: () async throws -> T) async rethrows -> T {
        try await closure()
    }
}

struct ActorAsyncPerformerFactoryImpl: AsyncPerformerFactory {
    func createAsyncPerformer() -> any AsyncPerformer {
        ActorAsyncPerformerImpl()
    }
}
