//
//  TaskLauncher.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol TaskLauncher {
    @discardableResult
    func launch<T: Sendable>(
        priority: TaskPriority,
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error>
}

extension TaskLauncher {
    @discardableResult
    func launch<T: Sendable>(
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        launch(priority: .medium, closure)
    }
}
