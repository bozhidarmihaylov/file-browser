//
//  LoadingStateSyncer.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol LoadingStateSyncer {
    func syncedLoadingStates(for entries: [Entry]) async throws -> [Entry]
}

struct LoadingStateSyncerImpl: LoadingStateSyncer {
    init(
        loadingRegistry: LoadingRegistry = LoadingRegistryImpl.shared
    ) {
        self.loadingRegistry = loadingRegistry
    }
    
    private let loadingRegistry: LoadingRegistry
    
    func syncedLoadingStates(for entries: [Entry]) async throws -> [Entry] {
        let states = try await loadingRegistry.downloadingStates(
            for: entries.map(\.path),
            in: entries.first?.bucketName ?? ""
        )
        
        return entries.enumerated().map { index, entry in
            Entry(
                name: entry.name,
                path: entry.path,
                bucketName: entry.bucketName,
                isFolder: entry.isFolder,
                loadingState: states[index]
            )
        }
    }
}
