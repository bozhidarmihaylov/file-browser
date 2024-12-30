//
//  Node.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol Node {
    var navigationNode: NavigationNode? { get }
    
    func present(_ node: Node, animated: Bool)
    func dismiss(animated: Bool)
}
