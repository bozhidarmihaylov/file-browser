//
//  TextField.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol TextField: View {
    var text: String? { get set }
//    var placeholder: String { get set }
//    var keyboardType: UIKeyboardType { get set }
    
    var isSecureTextEntry: Bool { get set }
    
    func becomeFirstResponder() -> Bool
}
