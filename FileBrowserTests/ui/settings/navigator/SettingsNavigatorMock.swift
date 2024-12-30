//
//  SettingsNavigatorMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SettingsNavigatorMock: SettingsNavigator {
    private(set) var goForwardCallCount: Int = 0
    func goForward() {
        goForwardCallCount += 1
    }
    
    private(set) var goBackCallCount: Int = 0
    func goBack() {
        goBackCallCount += 1
    }
}
