//
//  SceneDelegate.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var apiConfigProvider: ApiConfigProvider = ApiConfigStoreImpl.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        
        let identifier = apiConfigProvider.config
            .map { _ in "FileBrowserViewController" }
                ?? "SettingsViewController"

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = apiConfigProvider.config
//            .map { _ in FileBrowserViewController() }
//                ?? storyboard.instantiateViewController(withIdentifier: "SettingsViewController")

        
        let navVc = UINavigationController(rootViewController: vc)
        window.rootViewController = navVc
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

