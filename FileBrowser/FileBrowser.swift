//
//  FileBrowser.swift
//  FileBrowserFramework
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class FileBrowser {
    static let shared = FileBrowser()
    
    func createRootVc() -> UIViewController {
        apiConfigProvider.config
            .map { _ in
                navigationNodeFactory.createFileBrowserNode(
                    name: "/",
                    path: ""
                )
            } ?? 
        navigationNodeFactory.createSettingsNode()
    }
    
    private lazy var apiConfigProvider: ApiConfigProvider = ApiConfigStoreImpl.shared
    private lazy var navigationNodeFactory: NavigationNodeFactory = NavigationNodeFactoryImpl.shared
}
