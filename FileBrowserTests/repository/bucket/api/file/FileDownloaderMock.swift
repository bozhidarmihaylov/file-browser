//
//  FileDownloaderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileDownloaderMock: FileDownloader {
    private(set) var downloadFileCalls: [(
        path: String,
        config: ApiConfig
    )] = []
    
    var downloadFileResult: Entry! = nil
    var downloadFileError: Error? = nil
    func downloadFile(path: String, config: ApiConfig) async throws -> Entry {
        downloadFileCalls.append((
            path: path,
            config: config
        ))
        
        if let error = downloadFileError {
            throw error
        }
        
        return downloadFileResult
    }
}
