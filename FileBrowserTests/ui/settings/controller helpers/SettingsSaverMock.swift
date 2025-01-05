//
//  SettingsSaverMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SettingsSaverMock: SettingsSaver {
    private(set) var saveCallCount = 0
    
    func save() {
        saveCallCount += 1
    }
    
    var input: SettingsSaverInput!
    var output: SettingsSaverOutput!
}
