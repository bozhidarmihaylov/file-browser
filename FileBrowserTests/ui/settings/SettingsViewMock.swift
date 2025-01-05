//
//  SettingsViewMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SettingsViewMock: SettingsView {
    var node: Node! = NodeMock()
    
    var output: SettingsViewOutput? = nil
    
    var rootView: View! = ViewMock()
    
    var accessKeyTextField: TextField! = TextFieldMock()
    var secretKeyTextField: TextField! = TextFieldMock()
    var bucketNameTextField: TextField! = TextFieldMock()
    
    var saveButton: Button! = ButtonMock()
    
    var logoutButtonItem: ButtonItem! = ButtonItemMock()
    
    var backButtonItem: ButtonItem! = ButtonItemMock()
    
    private(set) var setTopBarButtonsVisibleCalls: [Bool] = []
    func setTopBarButtonsVisible(_ visible: Bool) {
        setTopBarButtonsVisibleCalls.append(visible)
    }
}
