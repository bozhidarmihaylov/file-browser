//
//  FileBrowserNavigatorImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

struct FileBrowserNavigatorImpl: FileBrowserNavigator {
    init(
        currentVc: UIViewController?,
        navigationNodeFactory: NavigationNodeFactory,
        localUrlFinder: LocalUrlFinder = LocalUrlFinderImpl.shared
    ) {
        self.currentVc = currentVc
        self.navigationNodeFactory = navigationNodeFactory
        self.localUrlFinder = localUrlFinder
    }
    
    private weak var currentVc: UIViewController?
    private let navigationNodeFactory: NavigationNodeFactory
    private let localUrlFinder: LocalUrlFinder
    
    func goToFolder(_ folder: Entry) {
        let vc = navigationNodeFactory.createFileBrowserNode(
            name: folder.name,
            path: folder.path
        )
        
        currentVc?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToFile(_ file: Entry) {
        let localUrl = localUrlFinder.localUrl(for: file.path, in: file.bucketName)
        let urlString = localUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
        
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func onRightButtonItemTap() {
        let vc = navigationNodeFactory.createSettingsNode()
        let navVc = UINavigationController(rootViewController: vc)

        navVc.modalPresentationStyle = .fullScreen
        navVc.modalTransitionStyle = .flipHorizontal

        currentVc?.present(navVc, animated: true)
    }
}
