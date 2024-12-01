//
//  SettingsNavigatorImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

struct SettingsNavigatorImpl: SettingsNavigator {
    init(
        currentVc: UIViewController?,
        navigationNodeFactory: NavigationNodeFactory
    ) {
        self.currentVc = currentVc
        self.navigationNodeFactory = navigationNodeFactory
    }
    
    private weak var currentVc: UIViewController?
    private let navigationNodeFactory: NavigationNodeFactory
    
    func goForward() {
        let vc = navigationNodeFactory.createFileBrowserNode(
            name: "/",
            path: ""
        )
        let navVc = UINavigationController(rootViewController: vc)
                            
        guard let window = currentVc?.view.window else { return }
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionFlipFromLeft]
        ) {
            window.rootViewController = navVc
        }
    }
    
    func goBack() {
        currentVc?.dismiss(animated: true)
    }
}
