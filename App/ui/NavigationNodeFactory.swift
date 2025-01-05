//
//  NavigationNodeFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

protocol NavigationNodeFactory {
    func createFileBrowserNode(name: String, path: String) -> UIViewController
    func createSettingsNode() -> UIViewController
}

struct NavigationNodeFactoryImpl: NavigationNodeFactory {
    static let shared: NavigationNodeFactory = NavigationNodeFactoryImpl()
    
    init(
        storyboard: UIStoryboard = UIStoryboard(
            name: "Main",
            bundle: Bundle(for: FileBrowser.self)
        )
    ) {
        self.storyboard = storyboard
    }
    
    var storyboard: UIStoryboard
    
    func createFileBrowserNode(name: String, path: String) -> UIViewController {
        let vc = createVc(identifier: "FileBrowserViewController") as! FileBrowserVc
        vc.title = name
        
        let navigator = FileBrowserNavigatorImpl(
            currentVc: vc,
            navigationNodeFactory: self
        )
        
        let folderContent = FolderContentImpl(
            path: path
        )
        
        let presenter = FileBrowserPresenterImpl(
            folderContent: folderContent
        )
        
        let controller = FileBrowserControllerImpl(
            path: path,
            folderContent: folderContent,
            navigator: navigator
        )
        controller.view = vc
        
        vc.input = presenter
        vc.output = controller
        
        controller.onInit()
        
        return vc
    }
    
    func createSettingsNode() -> UIViewController {
        let vc = createVc(identifier: "SettingsViewController") as! SettingsVc
        
        let navigator = SettingsNavigatorImpl(
            currentVc: vc,
            navigationNodeFactory: self
        )
        
        let controller = SettingsControllerImpl(
            navigator: navigator
        )
        controller.view = vc
        
        vc.output = controller
        
        return vc
    }
    
    private func createVc(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: Bundle(for: FileBrowser.self)
        )
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: identifier
        )

        return vc
    }
}
