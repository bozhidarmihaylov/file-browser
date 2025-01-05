//
//  SettingsSaver.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol SettingsSaver: AnyObject {
    func save()
    
    var input: SettingsSaverInput! { get set }
    var output: SettingsSaverOutput! { get set }
}

protocol SettingsSaverInput: AnyObject {
    func canSave() -> Bool
    
    func accessKey() -> String
    func secretKey() -> String
    
    func bucketName() -> String
}

protocol SettingsSaverOutput: AnyObject {
    func saveDidStart()
    func saveDidFinish(with result: Result<Void, Error>)
}

final class SettingsSaverImpl: SettingsSaver {
    init(
        configStore: ApiConfigStore = ApiConfigStoreImpl.shared,
        regionLoader: BucketRegionLoader = BucketRegionLoaderImpl.shared,
        taskLauncher: TaskLauncher = TaskLauncherImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl()
    ) {
        self.configStore = configStore
        self.regionLoader = regionLoader
        self.taskLauncher = taskLauncher
        self.mainActorRunner = mainActorRunner
    }
    
    private var configStore: ApiConfigStore
    private let regionLoader: BucketRegionLoader
    private let taskLauncher: TaskLauncher
    private let mainActorRunner: MainActorRunner
    
    weak var input: SettingsSaverInput!
    weak var output: SettingsSaverOutput!
    
    private var loaderTask: Task<Void, Error>? = nil
    
    func save() {
        
        guard let input, input.canSave() else {
            return
        }
        
        guard loaderTask == nil else {
            return
        }
        
        let credential = ApiCredential(
            accessKey: input.accessKey(),
            secretKey: input.secretKey()
        )
        
        let bucketName = input.bucketName()
        
        output.saveDidStart()
        
        loaderTask = taskLauncher.launch { [weak self] in
            guard let self else { return }
            
            do {
                let region = try await regionLoader.loadRegion(with: bucketName)
                
                let config = ApiConfig(
                    credential: credential,
                    bucket: Bucket(
                        name: bucketName,
                        region: region
                    )
                )
                                
                configStore.config = config
                
                await mainActorRunner.run { [weak self] in
                    guard let self, let output else { return }

                    defer { loaderTask = nil }
                    
                    output.saveDidFinish(with: .success(()))
                }
            } catch {
                defer { loaderTask = nil }
                
                await mainActorRunner.run { [weak self] in
                    guard let self, let output else { return }
                    
                    output.saveDidFinish(with: .failure(error))
                }
                
                NSLog("Failure saving config \(error)")
            }
        }
    }
}
