//
//  MainActorRunnerImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct MainActorRunnerImpl: MainActorRunner {
    func run<T>(body: @Sendable () throws -> T) async rethrows -> T {
        try await MainActor.run(body: body)
    }
}
