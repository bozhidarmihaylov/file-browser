//
//  NavigationNodeImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

struct NavigationNodeImpl: NavigationNode {
    init(
        navVc: UINavigationController
    ) {
        self.navVc = navVc
    }
    
    let navVc: UINavigationController
    
    func pushNode(_ node: Node, animated: Bool) {
        (node as? NodeImpl).map {
            navVc.pushViewController($0.vc, animated: animated)
        }
    }
    
    func popNode(animated: Bool) {
        navVc.popViewController(animated: animated)
    }
}
