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
        _ closure: @escaping () async throws -> T
    ) -> Task<T, Error>
}
