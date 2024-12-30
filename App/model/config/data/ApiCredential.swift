//
//  ApiCredential.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol ApiCredential {
    var accessKey: String { get }
    var secretKey: String { get }
}

struct ApiCredentialImpl: ApiCredential, Codable {
    var accessKey: String
    var secretKey: String
}
