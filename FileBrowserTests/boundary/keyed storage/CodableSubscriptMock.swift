//
//  CodableSubscriptMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class CodableSubscriptMock: CodableSubscript {    
    private var valueForKey: [String: Any?] = [:]
    
    private(set) var subscriptGetCalls: [String] = []
    private(set) var subscriptSetCalls: [(
        key: String,
        value: Any?
    )] = []
    
    subscript<T: Encodable>(
        codable key: String
    ) -> T? {
        get {
            subscriptGetCalls.append(key)
            return valueForKey[key] as? T
        }
        set(newValue) {
            subscriptSetCalls.append((key, newValue))
            valueForKey[key] = newValue
        }
    }
    
    private(set) var removeCalls: [String] = []
    
    func remove(_ key: String) {
        removeCalls.append(key)
        valueForKey.removeValue(forKey: key)
    }
}
