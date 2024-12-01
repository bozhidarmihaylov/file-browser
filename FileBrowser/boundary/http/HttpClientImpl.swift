//
//  HttpClientImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import CoreData
import UIKit

final class HttpClientImpl: NSObject {
    static let shared: HttpClientImpl = HttpClientImpl()
    
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
    
    func clearHangDownloads() async {
        let tasks = await runningDownloads()
        
        self.transferDelegate?.didRecreateBackgroundSession(with: tasks)
    }
    
    func runningDownloads() async -> [HttpTask] {
        await backgroundSession.tasks
            .2 // downloads
            .map(HttpTaskImpl.init)
    }
}

extension HttpClientImpl: URLSessionDownloadDelegate {
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        
        transferDelegate?.didFailDownloading(
            taskId: task.taskIdentifier,
            with: error
        )
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        transferDelegate?.didFinishDownloading(
            taskId: downloadTask.taskIdentifier,
            to: location
        )
    }
    
    func urlSessionDidFinishEvents(
        forBackgroundURLSession session: URLSession
    ) {
        guard session.configuration.identifier == Copy.downloadConfigId else { return }
        
        Task.detached {
            await self.clearHangDownloads()
            
            await MainActor.run {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                      let backgroundCompletionHandler =
                        appDelegate.handleEventsForBackgroundURLSessionCompletionHandler
                else { return }
                
                backgroundCompletionHandler()
            }
        }
    }
}
