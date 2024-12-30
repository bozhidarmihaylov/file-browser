//
//  Entry.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct Entry: Equatable {
    let name: String
    let path: String
    let bucketName: String
    let isFolder: Bool
    var loadingState: LoadingState
}

extension Entry {
    func copy(
        name: String? = nil,
        path: String? = nil,
        bucketName: String? = nil,
        isFolder: Bool? = nil,
        loadingState: LoadingState? = nil
    ) -> Entry {
        Entry(
            name: name ?? self.name,
            path: path ?? self.path,
            bucketName: bucketName ?? self.bucketName,
            isFolder: isFolder ?? self.isFolder,
            loadingState: loadingState ?? self.loadingState
        )
    }
}

enum LoadingState {
    case notLoaded
    case loading
    case loaded
}
