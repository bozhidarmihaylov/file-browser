//
//  ApiConfigStoreMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class ApiConfigStoreMock: ApiConfigStore {
    private(set) var configGetCallsCount: Int = 0
    private(set) var configSetCalls: [ApiConfig?] = []
    
    var _config: ApiConfig?
    var config: (ApiConfig)? {
        get {
            configGetCallsCount += 1
            return _config
        }
        set {
            configSetCalls.append(newValue)
            _config = newValue
        }
    }
}
