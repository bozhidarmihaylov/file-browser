//
//  TextFieldImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class TextFieldImpl: TextField {
    init(textField: UITextField) {
        _textField = textField
    }
    
    private let _textField: UITextField
    
    var text: String? {
        get { _textField.text }
        set { _textField.text = newValue }
    }
    
    var tag: Int {
        get { _textField.tag }
        set { _textField.tag = newValue }
    }
    
    var isSecureTextEntry: Bool {
        get { _textField.isSecureTextEntry }
        set { _textField.isSecureTextEntry = newValue }
    }
    
    func becomeFirstResponder() -> Bool {
        _textField.becomeFirstResponder()
    }
    
    var isHidden: Bool {
        get { _textField.isHidden }
        set { _textField.isHidden = newValue }
    }
    
    var isUserInteractionEnabled: Bool {
        get { _textField.isUserInteractionEnabled }
        set { _textField.isUserInteractionEnabled = newValue }
    }
}

extension UITextField {
    func toOurTextField() -> TextField {
        TextFieldImpl(textField: self)
    }
}
