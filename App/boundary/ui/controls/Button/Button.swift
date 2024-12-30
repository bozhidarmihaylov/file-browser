//
//  Button.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol Button: View {
    var isEnabled: Bool { get set }
    
    func setDefaultHighlight()
}
