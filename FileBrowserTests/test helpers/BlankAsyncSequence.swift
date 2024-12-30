//
//  BlankAsyncSequence.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

final class BlankAsyncSequence<Element>: AsyncSequence {
    typealias AsyncIterator = Iterator
    typealias Element = Element
    
    func makeAsyncIterator() -> Iterator {
        Iterator()
    }
    
    final class Iterator: AsyncIteratorProtocol {
        func next() async throws -> Element? { nil }
    }
}
