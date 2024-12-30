//
//  View.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol View: AnyObject {
    var tag: Int { get set }
    
    var isHidden: Bool { get set }
    
    var isUserInteractionEnabled: Bool { get set }
}
