//
//  FileBrowserCellVmFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import App

final class FileBrowserCellVmFactoryMock: FileBrowserCellVmFactory {
    private(set) var createVmCalls: [Entry] = []

    var createVmResult: EntryCellVm! = nil
    var createVmClosure: ((Entry) -> EntryCellVm)? = nil
    func createVm(entry: Entry) -> EntryCellVm {
        createVmCalls.append(entry)
        
        return createVmClosure?(entry) ?? createVmResult
    }
}
