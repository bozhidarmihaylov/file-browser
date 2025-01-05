//
//  NavigationNodeMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class NavigationNodeMock: NavigationNode {
    private(set) var pushNodeAnimatedCalls: [(
        node: Node,
        animated: Bool
    )] = []
    
    func pushNode(_ node: any Node, animated: Bool) {
        pushNodeAnimatedCalls.append((
            node: node,
            animated: animated
        ))
    }
    
    private(set) var popNodeAnimatedCalls: [Bool] = []
    
    func popNode(animated: Bool) {
        popNodeAnimatedCalls.append(animated)
    }
}
