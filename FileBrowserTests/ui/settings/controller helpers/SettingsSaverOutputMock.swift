//
//  SettingsSaverOutputMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class SettingsSaverOutputMock: SettingsSaverOutput {
    private(set) var saveDidStartCallCount = 0
    
    func saveDidStart() {
        saveDidStartCallCount += 1
    }
    
    private(set) var saveDidFinishWithResultCalls: [Result<Void, Error>] = []
    
    func saveDidFinish(with result: Result<Void, Error>) {
        saveDidFinishWithResultCalls.append(result)
    }
}
