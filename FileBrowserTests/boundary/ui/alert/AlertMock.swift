//
//  AlertMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AlertMock: Alert {
    private(set) var showOnNodeAnimatedCalls: [(
        node: Node,
        animated: Bool
    )] = []
    
    func show(on node: Node, animated: Bool) {
        showOnNodeAnimatedCalls.append((
            node: node,
            animated: animated
        ))
    }
    
    private(set) var hideAnimatedCalls: [Bool] = []
    
    func hide(animated: Bool) {
        hideAnimatedCalls.append(animated)
    }
}
