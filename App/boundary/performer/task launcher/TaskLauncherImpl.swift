//
//  TaskLauncherImpl.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct TaskLauncherImpl: TaskLauncher {
    func launch<T: Sendable>(
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        Task {
            try await closure()
        }
    }
}
