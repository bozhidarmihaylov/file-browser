//
//  AsyncSequenceIteratorMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AsyncSequenceIteratorMock<E>: AsyncIteratorProtocol {
    typealias Element = E

    private(set) var nextCallCount = 0
    
    var nextResult: E? = nil
    var nextError: Error? = nil
    func next() async throws -> E? {
        nextCallCount += 1
        
        if let error = nextError {
            throw error
        }
        
        return nextResult
    }
}
