//
//  AppDelegate.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var handleEventsForBackgroundURLSessionCompletionHandler: (() -> Void)? = nil
    
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        self.handleEventsForBackgroundURLSessionCompletionHandler = completionHandler
        Task.detached {
            await HttpClientImpl.shared.clearHangDownloads()
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        
    }
}

