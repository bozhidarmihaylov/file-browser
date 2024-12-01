//
//  FolderDao.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FolderDao {
    func get(
        path: String,
        bucketName: String
    ) async throws -> Entry?
    
    func getContents(
        path: String,
        bucketName: String
    ) async throws -> [Entry]?

    func mergeContentsPage(
        path: String,
        entries: [Entry],
        isFirst: Bool,
        isLast: Bool
    ) async throws
}
