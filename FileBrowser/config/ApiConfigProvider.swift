//
//  ApiConfigProvider.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol ApiConfigProvider {
    var config: ApiConfig? { get }
}

protocol ApiConfigStore: ApiConfigProvider {
    var config: ApiConfig? { get set }
}

struct ApiConfigStoreImpl: ApiConfigStore {
    init(
        keychain: CodableSubscript,
        preferences: CodableSubscript
    ) {
        self.keychain = keychain
        self.preferences = preferences
    }
    
    var keychain: CodableSubscript
    var preferences: CodableSubscript
    
    var config: ApiConfig? {
        get {
            guard let credential: ApiCredentialImpl = keychain[codable: Copy.credentialKey],
                  let bucket: BucketImpl = preferences[codable: Copy.bucketKey]
            else {
                return nil
            }
            
            return ApiConfigImpl(
                credential: credential,
                bucket: bucket
            )
        }
        set {
            guard let newValue else {
                keychain.remove(Copy.credentialKey)
                preferences.remove(Copy.bucketKey)
                return
            }
            keychain[codable: Copy.credentialKey] = ApiCredentialImpl(
                accessKey: newValue.credential.accessKey,
                secret: newValue.credential.secret
            )
            preferences[codable: Copy.bucketKey] = BucketImpl(
                name: newValue.bucket.name,
                region: newValue.bucket.region
            )
        }
    }
    
    static var shared: ApiConfigStore = ApiConfigStoreImpl(
        keychain: KeychainImpl.shared.codableSubscript,
        preferences: PreferencesImpl.shared.codableSubscript
    )
    
    private enum Copy {
        static let bucketKey = "aws-bucket"
        static let credentialKey = "aws-credential"
    }
}
