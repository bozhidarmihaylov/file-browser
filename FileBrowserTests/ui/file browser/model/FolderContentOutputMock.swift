//
//  FolderContentOutputMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentOutputMock: FolderContentOutput {
    private(set) var didAppendEntriesCalls: [[Entry]] = []
    
    func didAppendEntries(_ entries: [Entry]) {
        didAppendEntriesCalls.append(entries)
    }
    
    private(set) var didSyncLoadingStatesCallCount = 0
    
    func didSyncLoadingStates() {
        didSyncLoadingStatesCallCount += 1
    }
    
    private(set) var didUpdateLoadingStateAtIndexCalls: [Int] = []
    
    func didUpdateLoadingState(at index: Int) {
        didUpdateLoadingStateAtIndexCalls.append(index)
    }
}
