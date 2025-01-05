//
//  ButtonMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class ButtonMock: ViewMock, Button {
    var isEnabled: Bool = true
    
    private(set) var setDefaultHighlightCallCount = 0
    func setDefaultHighlight() {
        setDefaultHighlightCallCount += 1
    }
}
