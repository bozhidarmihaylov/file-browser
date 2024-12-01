//
//  ArraySequence.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ArraySequence<Element>: AsyncSequence {
    typealias AsyncIterator = Iterator
    typealias Element = Element
    
    let array: [Element]
    
    func makeAsyncIterator() -> Iterator {
        Iterator(array: array)
    }
    
    final class Iterator: AsyncIteratorProtocol {
        init(array: [Element]) {
            self.array = array
        }
        
        let array: [Element]
        var nextIndex: Int = 0
        
        func next() async throws -> Element? {
            guard array.indices.contains(nextIndex) else {
                return nil
            }
            let result = array[nextIndex]
            nextIndex += 1
            return result
        }
    }
}
