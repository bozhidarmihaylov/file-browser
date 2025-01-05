//
//  FolderContentPaginatorOutputMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FolderContentPaginatorOutputMock: FolderContentPaginatorOutput {
    private(set) var didStartLoadingNewPageCallCount = 0
    
    func didStartLoadingNewPage() {
        didStartLoadingNewPageCallCount += 1
    }
    
    private(set) var didFinishLoadingNewPageWithResultCalls: [Result<[Entry], Error>] = []
    
    func didFinishLoadingNewPage(with result: Result<[Entry], Error>) {
        didFinishLoadingNewPageWithResultCalls.append(result)
    }
}
