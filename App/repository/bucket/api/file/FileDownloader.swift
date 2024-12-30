//
//  FileDownloader.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileDownloader {
    func downloadFile(
        path: String,
        config: ApiConfig
    ) async throws -> Entry
}

final class FileDownloaderImpl {
    static let shared: FileDownloader = FileDownloaderImpl()
    
    init(
        requestFactory: FileDownloadRequestFactory = FileDownloadRequestFactoryImpl(),
        httpTransferClient: HttpTransferClient = HttpClientImpl.shared,
        loadingRegistry: LoadingRegistry = LoadingRegistryImpl.shared,
        transferDao: TransferDao = TransferDaoImpl(),
        syncPerformer: SyncPerformer = RecursiveLockSyncPerformerImpl(),
        fileTransferPlacer: FileTransferPlacer = FileTransferPlacerImpl(),
        fileSystem: FileSystem = FileSystemImpl(),
        taskLauncher: TaskLauncher = TaskLauncherImpl(),
        currentDateProvider: CurrentDateProvider = CurrentDateProviderImpl()
    ) {
        self.requestFactory = requestFactory
        self.httpTransferClient = httpTransferClient
        self.loadingRegistry = loadingRegistry
        self.transferDao = transferDao
        self.syncPerformer = syncPerformer
        self.fileTransferPlacer = fileTransferPlacer
        self.fileSystem = fileSystem
        self.taskLauncher = taskLauncher
        self.currentDateProvider = currentDateProvider
        
        httpTransferClient.transferDelegate = self
    }
    
    private let requestFactory: FileDownloadRequestFactory
    private let httpTransferClient: HttpTransferClient
    private let loadingRegistry: LoadingRegistry
    private let transferDao: TransferDao
    private let syncPerformer: SyncPerformer
    private let fileTransferPlacer: FileTransferPlacer
    private let fileSystem: FileSystem
    private let taskLauncher: TaskLauncher
    private let currentDateProvider: CurrentDateProvider
    
    private var continuationByTaskId: [Int: CheckedContinuation<URL, Error>] = [:]
}

extension FileDownloaderImpl: FileDownloader {
    func downloadFile(
        path: String,
        config: ApiConfig
    ) async throws -> Entry {
        let request = requestFactory.createDownloadRequest(
            filePath: path,
            with: config
        )

        let task = httpTransferClient.downloadFile(for: request)
        
        let taskId = task.identifier
        let bucketName = config.bucket.name
        let transfer = Transfer(
            relativeFilePath: path,
            bucketName: bucketName,
            taskIdentifier: taskId
        )
        
        try await loadingRegistry.registerTransfer(transfer)
        
        var unregisterError: Error? = nil
        do {
            let downloadUrl = try await withCheckedThrowingContinuation { continuation in
                syncPerformer.sync {
                    continuationByTaskId[taskId] = continuation
                }
                task.resume()                
            }
            
            try fileTransferPlacer.placeTransfer(transfer, from: downloadUrl)
            
            do {
                try await loadingRegistry.unregisterTransfer(transfer)
            } catch {
                unregisterError = error
                throw error
            }
        } catch {
            if unregisterError == nil {
                try await loadingRegistry.unregisterTransfer(transfer)
            }
            
            throw error
        }
        
        let entry = Entry(
            name: URL(fileURLWithPath: path).lastPathComponent,
            path: path,
            bucketName: bucketName,
            isFolder: false,
            loadingState: .loaded
        )
        
        return entry
    }
}

extension FileDownloaderImpl: HttpTransferDelegate {
    func didFailDownloading(
        taskId: Int,
        with error: Error
    ) {
        let continuation = syncPerformer.sync {
            continuationByTaskId.removeValue(forKey: taskId)
        }
        
        guard let continuation else {
            taskLauncher.launch {
                try? await self.loadingRegistry.unregisterTransfer(taskId: taskId)
            }
            return
        }
        
        continuation.resume(throwing: error)
    }
    
    func didFinishDownloading(
        taskId: Int,
        to url: URL
    ) {
        let continuation = syncPerformer.sync {
            continuationByTaskId.removeValue(forKey: taskId)
        }
        
        let date = currentDateProvider.currentDate
        
        let newUrl = fileSystem.temporaryDirectoryUrl
            .appendingPathComponent("download_task_#\(taskId)_\(date.timeIntervalSince1970)")
        
        do {
            try fileSystem.moveFile(at: url, to: newUrl)
        } catch {
            if let continuation {
                continuation.resume(throwing: error)
            } else {
                taskLauncher.launch {
                    try? await self.loadingRegistry.unregisterTransfer(
                        taskId: taskId
                    )
                }
            }
            return
        }
        
        guard let continuation else {
            taskLauncher.launch {
                if let transfer = try? await self.transferDao.get(taskId: taskId) {
                    try? self.fileTransferPlacer.placeTransfer(transfer, from: newUrl)
                }
                
                try? await self.loadingRegistry.unregisterTransfer(taskId: taskId)
            }
            return
        }
        
        continuation.resume(returning: newUrl)
    }
    
    func didRecreateBackgroundSession(with tasks: [HttpTask]) {
        taskLauncher.launch {
            let taskIds = tasks.map(\.identifier)
            _ = try? await self.transferDao.deleteTransfersWithTaskIdsNotIn(taskIds: taskIds)
        }
    }
}
