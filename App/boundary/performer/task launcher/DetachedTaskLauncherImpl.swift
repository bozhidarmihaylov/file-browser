//
//  DetachedTaskLauncherImpl.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct DetachedTaskLauncherImpl: TaskLauncher {
    func launch<T: Sendable>(
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        Task.detached {
            try await closure()
        }
    }
}
