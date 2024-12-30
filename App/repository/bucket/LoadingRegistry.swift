//
//  LoadingRegistry.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol LoadingRegistry {
    func registerTransfer(_ transfer: Transfer) async throws
    func unregisterTransfer(_ transfer: Transfer) async throws
    func unregisterTransfer(taskId: Int) async throws
    
    func downloadingState(
        for relativeFilePath: String,
        in bucketName: String
    ) async throws -> LoadingState
    
    func downloadingStates(
        for relativeFilePaths: [String],
        in bucketName: String
    ) async throws -> [LoadingState]
}

final class LoadingRegistryImpl: LoadingRegistry {
    static let shared: LoadingRegistry = LoadingRegistryImpl()
    
    init(
        fileSystem: FileSystem = FileSystemImpl.shared,
        asyncPerformer: AsyncPerformer = ActorAsyncPerformerImpl(),
        transferDao: TransferDao = TransferDaoImpl(),
        localUrlFinder: LocalUrlFinder = LocalUrlFinderImpl.shared
    ) {
        self.fileSystem = fileSystem
        self.asyncPerformer = asyncPerformer
        self.transferDao = transferDao
        self.localUrlFinder = localUrlFinder
    }
    
    private let fileSystem: FileSystem
    private let asyncPerformer: AsyncPerformer
    private let transferDao: TransferDao
    private let localUrlFinder: LocalUrlFinder
    
    private(set) var downloadsInProgress: Set<String> = Set()
    
    private var statesLoaded: Bool = false
    private func _loadStatesIfNeeded() async throws {
        guard !statesLoaded else { return }
        statesLoaded = true
        
        downloadsInProgress = Set(
            try await transferDao.getAll()
                .map { transfer in
                    localUrlFinder.localPath(
                        for: transfer.relativeFilePath,
                        in: transfer.bucketName
                    )
                }
        )
    }
    
    func downloadingState(
        for relativeFilePath: String,
        in bucketName: String
    ) async throws -> LoadingState {
        try await asyncPerformer.async {
            try await _loadStatesIfNeeded()
            
            let fullPath = self.localUrlFinder.localPath(
                for: relativeFilePath,
                in: bucketName
            )
            
            return _dowloadingState(atFullPath: fullPath)
        }
    }
    
    private func _dowloadingState(atFullPath fullPath: String) -> LoadingState {
        _isDownloadingFile(fullPath: fullPath)
            ? .loading
            : fileSystem.fileExists(atPath: fullPath)
                ? .loaded
                : .notLoaded
    }
    
    private func _isDownloadingFile(fullPath: String) -> Bool {
        downloadsInProgress.contains(fullPath)
    }
    
    func registerTransfer(_ transfer: Transfer) async throws {
        try await asyncPerformer.async {
            try await _loadStatesIfNeeded()
            
            let fullPath = localUrlFinder.localPath(
                for: transfer.relativeFilePath,
                in: transfer.bucketName
            )
            
            downloadsInProgress.insert(fullPath)
            
            try await transferDao.insertOrUpdate(
                transfer: transfer
            )
        }
    }
    
    private func _unregisterTransfer(_ transfer: Transfer) async throws {
        try await _loadStatesIfNeeded()
        
        let fullPath = localUrlFinder.localPath(
            for: transfer.relativeFilePath,
            in: transfer.bucketName
        )
        
        downloadsInProgress.remove(fullPath)
        
        _ = try await transferDao.delete(
            path: transfer.relativeFilePath,
            bucketName: transfer.bucketName
        )
    }
    
    func unregisterTransfer(_ transfer: Transfer) async throws {
        try await asyncPerformer.async {
            try await _unregisterTransfer(transfer)
        }
    }
    
    func unregisterTransfer(taskId: Int) async throws {
        try await asyncPerformer.async {
            guard let transfer = try await transferDao.get(taskId: taskId) else {
                return
            }

            return try await _unregisterTransfer(transfer)
        }
    }
    
    func downloadingStates(
        for relativeFilePaths: [String],
        in bucketName: String
    ) async throws -> [LoadingState] {
        try await asyncPerformer.async {
            try await _loadStatesIfNeeded()
            
            return relativeFilePaths.map { relativePath in
                localUrlFinder.localPath(
                    for: relativePath,
                    in: bucketName
                )
            }.map { fullPath in
                _dowloadingState(atFullPath: fullPath)
            }
        }
    }
}
