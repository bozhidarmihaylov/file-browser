//
//  ApiCredential.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol ApiCredential {
    var accessKey: String { get }
    var secret: String { get }
}

struct ApiCredentialImpl: ApiCredential, Codable {
    var accessKey: String
    var secret: String
}
