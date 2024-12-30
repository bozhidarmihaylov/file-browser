//
//  CellVm.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

enum AccessoryVm {
    case spinner
    case image(systemName: String)
    case imageButton(systemName: String)
}

struct EntryCellVm {
    let iconName: String
    let text: String
    let accessoryVm: AccessoryVm
    
    let isSelectable: Bool
}
