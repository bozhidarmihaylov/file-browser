//
//  FolderContentLoaderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentLoaderMock: FolderContentLoader {
    private(set) var getContentWithPathContinuationTokenPageSizeConfigCalls: [(
        path: String,
        continuationToken: String?,
        pageSize: Int,
        config: ApiConfig
    )] = []
    
    var getContentPathContinuationTokenPageSizeConfigResult: FolderContentPage! = nil
    var getContentPathContinuationTokenPageSizeConfigError: Error? = nil
    func getContent(
        path: String, 
        continuationToken: String?, 
        pageSize: Int, 
        config: ApiConfig
    ) async throws -> FolderContentPage {
        getContentWithPathContinuationTokenPageSizeConfigCalls.append((
            path: path,
            continuationToken: continuationToken,
            pageSize: pageSize,
            config: config
        ))
        
        if let error = getContentPathContinuationTokenPageSizeConfigError {
            throw error
        }
        
        return getContentPathContinuationTokenPageSizeConfigResult
    }
}
