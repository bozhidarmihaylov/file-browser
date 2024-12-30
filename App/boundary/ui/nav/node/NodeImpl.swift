//
//  NodeImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

struct NodeImpl: Node {
    init(
        vc: UIViewController
    ) {
        self.vc = vc
    }
    
    let vc: UIViewController
    
    var navigationNode: NavigationNode? {
        vc.navigationController.map {
            NavigationNodeImpl(
                navVc: $0
            )
        }!
    }
    
    func present(_ node: Node, animated: Bool) {
        (node as? NodeImpl).map {
            vc.present($0.vc, animated: animated)
        }
    }
    
    func dismiss(animated: Bool) {
        vc.dismiss(animated: animated)
    }
}
