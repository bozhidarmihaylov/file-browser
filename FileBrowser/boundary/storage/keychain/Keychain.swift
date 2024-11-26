//
//  Keychain.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import KeychainAccess

protocol Keychain: DataSubscript {}

struct KeychainImpl: Keychain {
    init(service: String) {
        keychain = KeychainAccess.Keychain(service: service)
    }
    
    private let keychain: KeychainAccess.Keychain
    
    subscript(data key: String) -> Data? {
        get {
            keychain[data: key]
        }
        set {
            guard let newValue else {
                remove(key)
                return
            }
            keychain[data: key] = newValue
        }
    }
    
    func remove(_ key: String) {
        try? keychain.remove(key)
    }
    
    static let shared: Keychain = KeychainImpl(service: Copy.serviceKey)
    
    private enum Copy {
        static let serviceKey = "aws-bucket-keys"
    }
}
