//
//  FileBrowserNavigatorMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import App

final class FileBrowserNavigatorMock: FileBrowserNavigator {
    private(set) var goToFileCalls: [Entry] = []
    func goToFile(_ file: Entry) {
        goToFileCalls.append(file)
    }
    
    private(set) var goToFolderCalls: [Entry] = []
    func goToFolder(_ folder: Entry) {
        goToFolderCalls.append(folder)
    }
    
    private(set) var onRightButtonItemTapCallCount: Int = 0
    func onRightButtonItemTap() {
        onRightButtonItemTapCallCount += 1
    }
}
