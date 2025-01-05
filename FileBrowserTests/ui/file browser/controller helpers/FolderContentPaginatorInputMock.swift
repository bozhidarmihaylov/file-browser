//
//  FolderContentPaginatorInputMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentPaginatorInputMock: FolderContentPaginatorInput {
    private(set) var loadNextPageCallCount: Int = 0
    
    var loadNextPageResult: [Entry]? = nil
    var loadNextPageError: Error? = nil
    func loadNextPage() async throws -> [Entry]? {
        loadNextPageCallCount += 1
        
        if let error = loadNextPageError {
            throw error
        }
        
        return loadNextPageResult
    }
}
