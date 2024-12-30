//
//  AsyncPerformerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AsyncPerformerMock: AsyncPerformer {    
    func async<T>(_ closure: () async throws -> T) async rethrows -> T {
        return try await closure()
    }
}
