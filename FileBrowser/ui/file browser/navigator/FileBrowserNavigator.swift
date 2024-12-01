//
//  FileBrowserNavigator.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol FileBrowserNavigator {
    func goToFile(_ file: Entry)
    func goToFolder(_ folder: Entry)
    
    func onRightButtonItemTap()
}
