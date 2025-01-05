//
//  FolderContentMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentMock: FolderContent {
    
    private(set) var numberOfEntriesCallCount: Int = 0
    
    var numberOfEntriesResult: Int! = nil
    func numberOfEntries() -> Int {
        numberOfEntriesCallCount += 1
        
        return numberOfEntriesResult
    }
    
    private(set) var entryAtIndexCalls: [Int] = []
    
    var entryAtIndexResult: Entry! = nil
    var entryAtIndexClosure: ((Int) -> Entry)? = nil
    func entry(at index: Int) -> Entry {
        entryAtIndexCalls.append(index)
        
        return entryAtIndexClosure?(index) ?? entryAtIndexResult
    }
    
    private(set) var appendEntriesCalls: [[Entry]] = []
    
    func append(entries: [Entry]) {
        appendEntriesCalls.append(entries)
    }
    
    private(set) var syncLoadingStatesCallCount: Int = 0
    
    var syncLoadingStatesError: Error? = nil
    func syncLoadingStates() async throws {
        syncLoadingStatesCallCount += 1
        
        if let error = syncLoadingStatesError {
            throw error
        }
    }
    
    private(set) var setLoadingStateAtPathCalls: [(
        loadingState: LoadingState,
        path: String
    )] = []
    
    func setLoadingState(_ loadingState: LoadingState, at path: String) {
        setLoadingStateAtPathCalls.append((
            loadingState: loadingState,
            path: path
        ))
    }
    
    weak var output: FolderContentOutput?
}
