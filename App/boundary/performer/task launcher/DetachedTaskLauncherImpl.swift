//
//  DetachedTaskLauncherImpl.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct DetachedTaskLauncherImpl: TaskLauncher {
    func launch<T: Sendable>(
        priority: TaskPriority,
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        Task.detached(priority: priority) {
            try await closure()
        }
    }
}
