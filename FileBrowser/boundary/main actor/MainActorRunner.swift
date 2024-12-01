//
//  MainActorRunner.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol MainActorRunner {
    func run<T>(body: @Sendable () throws -> T) async rethrows -> T
}
