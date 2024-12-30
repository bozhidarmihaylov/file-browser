//
//  FileBrowserCellVmFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol FileBrowserCellVmFactory {
    func createVm(entry: Entry) -> EntryCellVm
    
    func createVm(entries: [Entry]) -> [EntryCellVm]
}

extension FileBrowserCellVmFactory {
    func createVm(entries: [Entry]) -> [EntryCellVm] {
        entries.map(createVm)
    }
}

struct FileBrowserVmFactoryImpl: FileBrowserCellVmFactory {
    func createVm(entry: Entry) -> EntryCellVm {
        EntryCellVm(
            iconName: entry.isFolder ? "folder" : "doc",
            text: entry.name,
            accessoryVm: {
                if entry.isFolder {
                    return .image(systemName: "chevron.forward")
                }
                switch entry.loadingState {
                case .notLoaded:
                    return .imageButton(systemName: "arrow.down.circle.dotted")
                case .loading:
                    return .spinner
                case .loaded:
                    return .imageButton(systemName: "arrow.clockwise.circle")
                }
            }(),
            isSelectable: entry.isFolder || entry.loadingState == .loaded
        )
    }
}
