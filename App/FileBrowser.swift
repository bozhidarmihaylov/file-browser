//
//  FileBrowser.swift
//  FileBrowserFramework
//
//  Created by Bozhidar Mihaylov
//

import UIKit

public final class FileBrowser {
    public static let shared = FileBrowser()
    
    public func createRootVc() -> UIViewController {
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
