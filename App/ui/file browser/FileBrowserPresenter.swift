//
//  FileBrowserPresenter.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileBrowserPresenter: FileBrowserViewInput {
    
}

final class FileBrowserPresenterImpl {
    init(
        folderContent: FolderContent,
        cellVmFactory: FileBrowserCellVmFactory = FileBrowserCellVmFactoryImpl()
    ) {
        self.folderContent = folderContent
        self.cellVmFactory = cellVmFactory
        
        folderContent.output = self
    }
    
    private let folderContent: FolderContent
    private let cellVmFactory: FileBrowserCellVmFactory
    
    private(set) var cellVms: [EntryCellVm] = []
}

extension FileBrowserPresenterImpl: FileBrowserPresenter {
    func cellCount() -> Int {
        cellVms.count
    }
    
    func cellVm(at indexPath: IndexPath) -> EntryCellVm {
        cellVms[indexPath.row]
    }
}

extension FileBrowserPresenterImpl: FolderContentOutput {
    func didAppendEntries(_ entries: [Entry]) {
        let newCellVms = cellVmFactory.createVm(entries: entries)
        
        cellVms.append(contentsOf: newCellVms)
    }
    
    func didSyncLoadingStates() {
        cellVms = (0..<folderContent.numberOfEntries())
            .map(folderContent.entry)
            .map(cellVmFactory.createVm)
    }
    
    func didUpdateLoadingState(at index: Int) {
        let entry = folderContent.entry(at: index)
        let cellVm = cellVmFactory.createVm(entry: entry)
        
        cellVms[index] = cellVm        
    }
}
