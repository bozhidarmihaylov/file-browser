//
//  ApiConfig+mock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

extension ApiConfig {
    static let mock = ApiConfig(
        credential: .mock,
        bucket: .mock)
}

extension ApiCredential {
    static let mock = ApiCredential(
        accessKey: "access-key",
        secretKey: "secret-key"
    )
}

extension Bucket {
    static let mock = Bucket(
        name: "test-bucket",
        region: "test-aws-region"
    )
}
