//
//  CellVm.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

enum AccessoryVm: Equatable {
    case spinner
    case image(systemName: String)
    case imageButton(systemName: String)
}

struct EntryCellVm: Equatable {
    let iconName: String
    let text: String
    let accessoryVm: AccessoryVm
    
    let isSelectable: Bool
}

extension EntryCellVm {
    func copy(
        iconName: String? = nil,
        text: String? = nil,
        accessoryVm: AccessoryVm? = nil,
        isSelectable: Bool? = nil
    ) -> EntryCellVm {
        EntryCellVm(
            iconName: iconName ?? self.iconName,
            text: text ?? self.text,
            accessoryVm: accessoryVm ?? self.accessoryVm,
            isSelectable: isSelectable ?? self.isSelectable
        )
    }
}
