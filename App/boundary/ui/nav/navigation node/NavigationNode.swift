//
//  NavigationNode.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol NavigationNode {
    func pushNode(_ node: Node, animated: Bool)
    func popNode(animated: Bool)
}
