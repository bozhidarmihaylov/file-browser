//
//  AlertBuilder.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol AlertBuilder: AnyObject {
    func setTitle(_ title: String?) -> AlertBuilder
    func setMessage(_ messsage: String?) -> AlertBuilder
    func setCancelButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder
    func setOkButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder
    
    func build() -> Alert
}

typealias AlertAction = (Alert) -> Void

protocol Alert {
    func show(on node: Node, animated: Bool)
    func hide(animated: Bool)
}
