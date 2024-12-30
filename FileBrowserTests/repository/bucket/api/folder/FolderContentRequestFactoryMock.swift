//
//  FolderContentRequestFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentRequestFactoryMock: FolderContentRequestFactory {
    private(set) var createListRequestWithPathContinuationTokenPageSizeConfigCalls: [(
        folderPath: String,
        continuationToken: String?,
        pageSize: Int,
        config: ApiConfig
    )] = []
    
    var createListRequestWithPathContinuationTokenPageSizeConfigResult: URLRequest! = nil
    func createListRequest(
        folderPath: String, 
        continuationToken: String?, 
        pageSize: Int, 
        with config: ApiConfig
    ) -> URLRequest {
        createListRequestWithPathContinuationTokenPageSizeConfigCalls.append((
            folderPath: folderPath,
            continuationToken: continuationToken,
            pageSize: pageSize,
            config: config
        ))
        
        return createListRequestWithPathContinuationTokenPageSizeConfigResult
    }
}
