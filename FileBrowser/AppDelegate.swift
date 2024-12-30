//
//  AppDelegate.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import App

@main
class AppDelegate: UIResponder, UIApplicationDelegate, BackgroundSessionEventsCompletionProvider {
    var backgroundSessionEventsCompletion: (() -> Void)?
    
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        backgroundSessionEventsCompletion = completionHandler
        HttpClientImpl.shared.backgroundSessionEventsCompletionProvider = self
        
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

