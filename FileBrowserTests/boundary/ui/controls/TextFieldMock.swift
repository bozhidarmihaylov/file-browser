//
//  TextFieldMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class TextFieldMock: ViewMock, TextField {
    var text: String? = nil
    var isSecureTextEntry: Bool = false
    
    var becomeFirstResponderCallCount = 0
    var becomeFirstResponderResult = true
    func becomeFirstResponder() -> Bool {
        becomeFirstResponderCallCount += 1
        
        return becomeFirstResponderResult
    }
}
