//
//  FileBrowserCellVmFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import FileBrowser

final class FileBrowserCellVmFactoryMock: FileBrowserCellVmFactory {
    func createVm(entry: Entry) -> EntryCellVm {
        EntryCellVm(
            iconName: "",
            text: "",
            accessoryVm: .spinner,
            isSelectable: false
        )
    }
}
