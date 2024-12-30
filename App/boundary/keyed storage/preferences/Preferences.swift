//
//  Preferences.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol Preferences: DataSubscript {}

struct PreferencesImpl: Preferences {
    static let shared: Preferences = PreferencesImpl(preferences: .standard)
    
    init(
        preferences: UserDefaults
    ) {
        self.preferences = preferences
    }
    
    private let preferences: UserDefaults
    
    subscript(data key: String) -> Data? {
        get {
            preferences.data(forKey: key)
        }
        set {
            guard let newValue else {
                remove(key)
                return
            }
            preferences.set(newValue, forKey: key)
        }
    }
    
    mutating func remove(_ key: String) {
        preferences.removeObject(forKey: key)
    }
}
