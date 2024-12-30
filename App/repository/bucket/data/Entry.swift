//
//  Entry.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct Entry {
    let name: String
    let path: String
    let bucketName: String
    let isFolder: Bool
    var loadingState: LoadingState
}

enum LoadingState {
    case notLoaded
    case loading
    case loaded
}
