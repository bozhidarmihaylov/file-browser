//
//  ArrayAsyncSequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ArrayAsyncSequence<Element>: AsyncSequence {
    typealias AsyncIterator = Iterator
    typealias Element = Element
    
    init(
        array: [Element], 
        isFinite: Bool = true
    ) {
        self.array = array
        self.isFinite = isFinite
    }
    
    private let array: [Element]
    private let isFinite: Bool
    
    func makeAsyncIterator() -> Iterator {
        Iterator(array: array, isFinite: isFinite)
    }
    
    final class Iterator: AsyncIteratorProtocol {
        init(
            array: [Element],
            isFinite: Bool
        ) {
            self.array = array
            self.isFinite = isFinite
        }
        
        private var array: [Element]
        private let isFinite: Bool
        private var nextIndex: Int = 0
        
        private var continuation: CheckedContinuation<Element, Never>? = nil
        
        func addElements(_ elements: [Element]) {
            guard let first = elements.first else {
                return
            }
            
            array.append(contentsOf: elements)
            continuation?.resume(returning: first)
            continuation = nil
        }
        
        func next() async throws -> Element? {
            guard array.indices.contains(nextIndex) else {
                if isFinite { return nil }
                
                return await withCheckedContinuation { continuation in
                    self.continuation = continuation
                }
            }
            
            let result = array[nextIndex]
            nextIndex += 1
            
            return result
        }
    }
}
