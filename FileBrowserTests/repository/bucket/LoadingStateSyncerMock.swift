//
//  LoadingStateSyncerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class LoadingStateSyncerMock: LoadingStateSyncer {
    private(set) var syncedLoadingStatesForEntriesCalls: [[Entry]] = []
    
    var syncedLoadingStatesForEntriesResult: [Entry]! = nil
    var syncedLoadingStatesForEntriesError: Error? = nil
    func syncedLoadingStates(for entries: [Entry]) async throws -> [Entry] {
        syncedLoadingStatesForEntriesCalls.append(entries)
        
        if let error = syncedLoadingStatesForEntriesError {
            throw error
        }
        
        return syncedLoadingStatesForEntriesResult
    }
}
