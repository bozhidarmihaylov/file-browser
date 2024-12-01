//
//  HttpTransferClient.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol HttpTransferClient: AnyObject {
    func downloadFile(for request: URLRequest) -> HttpTask
    func clearHangDownloads() async
    
    func runningDownloads() async -> [HttpTask]
    
    var transferDelegate: HttpTransferDelegate? { get set }
}

protocol HttpTransferDelegate: AnyObject {
    func didFinishDownloading(
        taskId: Int,
        to url: URL
    )
    
    func didFailDownloading(
        taskId: Int,
        with error: Error
    )
    
    func didRecreateBackgroundSession(with tasks: [HttpTask])
}
