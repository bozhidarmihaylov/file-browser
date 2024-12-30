//
//  AlertBuilder.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol AlertBuilder {
    mutating func setTitle(_ title: String?) -> AlertBuilder
    mutating func setMessage(_ messsage: String?) -> AlertBuilder
    mutating func setCancelButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder
    mutating func setOKButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder
    
    func build() -> Alert
}

typealias AlertAction = (Alert) -> Void

protocol Alert {
    func show(on node: Node, animated: Bool)
    func hide(animated: Bool)
}
