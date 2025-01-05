//
//  FileBrowserViewMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileBrowserViewMock: FileBrowserView {
    var nodeResult: Node! = nil
    var node: Node { nodeResult }
    
    var visibleIndexPaths: [IndexPath] = []
    
    private(set) var reloadDataCallCount: Int = 0
    
    func reloadData() {
        reloadDataCallCount += 1
    }
    
    private(set) var insertRowsCalls: [(
        indexPath: IndexPath,
        count: Int
    )] = []
    
    func insertRows(at indexPath: IndexPath, count: Int) {
        insertRowsCalls.append((
            indexPath: indexPath,
            count: count
        ))
    }
    
    private(set) var updateAccessoryViewForRowsAtIndexPathsCalls: [[IndexPath]] = []
    
    func updateAccessoryViewForRows(at indexPaths: [IndexPath]) {
        updateAccessoryViewForRowsAtIndexPathsCalls.append(indexPaths)
    }
    
    private(set) var deselectCellAtIndexPathCalls: [IndexPath] = []
    
    func deselectCell(at indexPath: IndexPath) {
        deselectCellAtIndexPathCalls.append(indexPath)
    }
}
