//
//  ApiConfig.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol ApiConfig {
    var bucket: Bucket { get }
    var credential: ApiCredential { get }
}

struct ApiConfigImpl: ApiConfig {
    let credential: ApiCredential
    let bucket: Bucket
}
