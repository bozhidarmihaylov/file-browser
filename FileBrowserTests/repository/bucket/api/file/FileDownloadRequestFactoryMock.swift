//
//  FileDownloadRequestFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileDownloadRequestFactoryMock: FileDownloadRequestFactory {
    private(set) var createDownloadRequestCalls: [(
        filePath: String,
        config: ApiConfig
    )] = []
    
    var createDownloadRequestResult: URLRequest! = nil
    func createDownloadRequest(
        filePath: String, 
        with config: ApiConfig
    ) -> URLRequest {
        createDownloadRequestCalls.append((
            filePath: filePath,
            config: config
        ))
        
        return createDownloadRequestResult
    }
}
