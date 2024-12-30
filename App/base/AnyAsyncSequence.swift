//
//  AnyAsyncSequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct AnyAsyncIterator<E>: AsyncIteratorProtocol {
    init<I: AsyncIteratorProtocol>(iterator: I) where I.Element == E {
        var i = iterator
        _next = { return try await i.next() }
    }
    
    private let _next: () async throws -> E?
    
    mutating func next() async throws -> E? {
        try await _next()
    }
}

struct AnyAsyncSequence<E>: AsyncSequence {
    typealias AsyncIterator = AnyAsyncIterator<Element>
    
    typealias Element = E

    init<S: AsyncSequence>(
        sequence: inout S
    ) where S.Element == E {
        self.init(
            sequence: &sequence,
            id: UUID().uuidString
        )
    }
    
    init<S: AsyncSequence>(
        sequence: inout S,
        id: some Hashable
    ) where S.Element == E {
        self.id = id
        
        _makeIterator = { [sequence] in
            AnyAsyncIterator(
                iterator: sequence.makeAsyncIterator()
            )
        }
    }
    
    let id: AnyHashable
    
    private let _makeIterator: () -> AnyAsyncIterator<E>
    
    func makeAsyncIterator() -> AnyAsyncIterator<Element> {
        _makeIterator()
    }
}
