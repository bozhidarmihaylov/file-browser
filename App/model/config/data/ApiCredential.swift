//
//  ApiCredential.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ApiCredential: Codable, Equatable {
    let accessKey: String
    let secretKey: String
}
