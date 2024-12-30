//
//  ButtonItemImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class ButtonItemImpl: ButtonItem {
    init(buttonItem: UIBarButtonItem) {
        _buttonItem = buttonItem
    }
    private let _buttonItem: UIBarButtonItem
    
    var isHidden: Bool {
        get { _buttonItem.isHidden }
        set { _buttonItem.isHidden = newValue }
    }
}

extension UIBarButtonItem {
    func toOurButtonItem() -> ButtonItem {
        ButtonItemImpl(buttonItem: self)
    }
}
