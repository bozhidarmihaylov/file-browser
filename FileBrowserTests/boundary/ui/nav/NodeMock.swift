//
//  NodeMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class NodeMock: Node {
    var navigationNode: NavigationNode?
    
    private(set) var presentNodeAnimatedCalls: [(
        node: Node,
        animated: Bool
    )] = []
    
    func present(_ node: any Node, animated: Bool) {
        presentNodeAnimatedCalls.append((
            node: node,
            animated: animated
        ))
    }
    
    private(set) var dismissAnimatedCalls: [Bool] = []
    
    func dismiss(animated: Bool) {
        dismissAnimatedCalls.append(animated)
    }
}
