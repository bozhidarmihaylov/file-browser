//
//  TaskLauncherImpl.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct TaskLauncherImpl: TaskLauncher {
    func launch<T: Sendable>(
        priority: TaskPriority,
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        Task(priority: priority) {
            try await closure()
        }
    }
}
