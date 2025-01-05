//
//  AsyncSequenceMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AsyncSequenceMock<E>: AsyncSequence {
    typealias AsyncIterator = AsyncSequenceIteratorMock<E>
    typealias Element = E
    
    private(set) var makeAsyncIteratorCallCount = 0
    
    var makeAsyncIteratorResult: AsyncIterator! = nil
    func makeAsyncIterator() -> AsyncIterator {
        makeAsyncIteratorCallCount += 1
        
        return makeAsyncIteratorResult
    }
}
