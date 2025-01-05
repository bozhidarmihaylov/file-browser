//
//  SettingsSaverInputMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SettingsSaverInputMock: SettingsSaverInput {
    private(set) var canSaveCallCount = 0
    
    var canSaveResult: Bool! = nil
    func canSave() -> Bool {
        canSaveCallCount += 1
        
        return canSaveResult
    }
    
    private(set) var accessKeyCallCount = 0
    
    var accessKeyResult: String! = nil
    func accessKey() -> String {
        accessKeyCallCount += 1
        
        return accessKeyResult
    }
    
    private(set) var secretKeyCallCount = 0
    
    var secretKeyResult: String! = nil
    func secretKey() -> String {
        secretKeyCallCount += 1
        
        return secretKeyResult
    }
    
    private(set) var bucketNameCallCount = 0
    
    var bucketNameResult: String! = nil
    func bucketName() -> String {
        bucketNameCallCount += 1
        
        return bucketNameResult
    }
}
