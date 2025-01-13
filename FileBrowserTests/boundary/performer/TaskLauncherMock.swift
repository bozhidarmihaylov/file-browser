//
//  TaskLauncherMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class TaskLauncherMock: TaskLauncher {
    private(set) var launchCallPriorities: [TaskPriority] = []
    private(set) var launchTasks: [Task<Sendable, Error>] = []
    func launch<T: Sendable>(
        priority: TaskPriority,
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error> {
        launchCallPriorities.append(priority)
        
        let task = Task.detached {
            try await closure()
        }
        
        let wrapperTask = Task.detached {
            try await withTaskCancellationHandler {
                try await task.value as Sendable
            } onCancel: {
                task.cancel()
            }
        }
        
        launchTasks.append(wrapperTask)
        
        return task
    }
    
    func awaitTasks() async throws {
        for task in launchTasks {
            _ = try await task.result.get()
        }
    }
}
