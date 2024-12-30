//
//  HttpTransferClientMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class HttpTransferClientMock: HttpTransferClient {
    private(set) var downloadFileForRequestCalls: [URLRequest] = []
    
    var downloadFileForRequestResult: HttpTask! = nil
    func downloadFile(for request: URLRequest) -> HttpTask {
        downloadFileForRequestCalls.append(request)
        
        return downloadFileForRequestResult
    }
    
    private(set) var clearHangDownloadsCallCount: Int = 0
    func clearHangDownloads() async {
        clearHangDownloadsCallCount += 1
    }
    
    private(set) var runningDownloadsCallCount: Int = 0
    
    var runningDownloadsResult: [HttpTask]! = nil
    func runningDownloads() async -> [HttpTask] {
        runningDownloadsCallCount += 1
        
        return runningDownloadsResult
    }
    
    var transferDelegate: (HttpTransferDelegate)?
}
