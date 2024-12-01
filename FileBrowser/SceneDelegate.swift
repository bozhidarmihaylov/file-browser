//
//  SceneDelegate.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import XMLCoder

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let vc = FileBrowser.shared.createRootVc()
        
        let navVc = UINavigationController(rootViewController: vc)
        
        window.rootViewController = navVc
        
//        let request = FileDownloadRequestFactoryImpl().createDownloadRequest(
//            filePath:
//                "/book.mixu.net-Distributed systems.pdf",
////                "/jdk-master/Makefile",
//            with: ApiConfigStoreImpl.shared.config!
//        )
        
//        let request = FolderContentRequestFactoryImpl().createListRequest(
//            folderPath:
//                "jdk-master/src/",
//            continuationToken: nil,
//            pageSize: 20,
//            with: ApiConfigStoreImpl.shared.config!
//        )
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            let xmlDecoder = XMLDecoder()
//            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
//            xmlDecoder.dateDecodingStrategy = .formatted(formatter)
//            
//            guard let data,
//                  let xml = try? xmlDecoder.decode(ListBucketResult.self, from: data)
//            else { return }
//
//            
//            NSLog("\(xml)")
//            NSLog("")
//        }.resume()
        
        _ = CoreDataStack.shared
        Task.detached {
            await HttpClientImpl.shared.clearHangDownloads()
        }
        
        print(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first)
        
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

