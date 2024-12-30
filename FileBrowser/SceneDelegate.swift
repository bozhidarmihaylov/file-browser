//
//  SceneDelegate.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import XMLCoder
import App

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let vc = FileBrowser.shared.createRootVc()
        
        let navVc = UINavigationController(rootViewController: vc)
        
        window.rootViewController = navVc
        
        _ = CoreDataStack.shared
        Task.detached {
            await HttpClientImpl.shared.clearHangDownloads()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

