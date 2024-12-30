//
//  MainActorRunnerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class MainActorRunnerMock: MainActorRunner {
    func run<T>(body: @Sendable () throws -> T) async rethrows -> T {
        try body()
    }
}
