//
//  FolderContentPaginatorMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentPaginatorMock: FolderContentPaginator {
    private(set) var loadMoreCallCount = 0
    
    func loadMore() {
        loadMoreCallCount += 1
    }    
    
    var input: FolderContentPaginatorInput!
    var output: FolderContentPaginatorOutput!
}
