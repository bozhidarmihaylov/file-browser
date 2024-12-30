//
//  HttpClientImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import CoreData
import UIKit

public final class HttpClientImpl: NSObject {
    public static let shared: HttpClientImpl = HttpClientImpl()
    
    public var backgroundSessionEventsCompletionProvider: BackgroundSessionEventsCompletionProvider? = nil
    
    weak var transferDelegate: HttpTransferDelegate? = nil
    
    private lazy var session: URLSession = .shared
    private lazy var backgroundSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: Copy.downloadConfigId)
        config.sessionSendsLaunchEvents = true
        
        let result = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
        
        return result
    }()
    
    private enum Copy {
        static let downloadConfigId = "FileDownload"
    }
}

extension HttpClientImpl: HttpClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

extension HttpClientImpl: HttpTransferClient {
    func downloadFile(for request: URLRequest) -> HttpTask {
        HttpTaskImpl(
            underlying: backgroundSession.downloadTask(with: request)
        )
    }
    
    public func clearHangDownloads() async {
        let tasks = await runningDownloads()
        
        _ = FileDownloaderImpl.shared
        self.transferDelegate?.didRecreateBackgroundSession(with: tasks)
    }
    
    func runningDownloads() async -> [HttpTask] {
        await backgroundSession.tasks
            .2 // downloads
            .map(HttpTaskImpl.init)
    }
}

extension HttpClientImpl: URLSessionDownloadDelegate {
    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        
        transferDelegate?.didFailDownloading(
            taskId: task.taskIdentifier,
            with: error
        )
    }
    
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        transferDelegate?.didFinishDownloading(
            taskId: downloadTask.taskIdentifier,
            to: location
        )
    }
    
    public func urlSessionDidFinishEvents(
        forBackgroundURLSession session: URLSession
    ) {
        guard session.configuration.identifier == Copy.downloadConfigId else { return }
        
        Task.detached {
            await self.clearHangDownloads()
            
            await MainActor.run {
                guard let completion = self.backgroundSessionEventsCompletionProvider?
                    .backgroundSessionEventsCompletion
                else { return }
                
                completion()
            }
        }
    }
}
