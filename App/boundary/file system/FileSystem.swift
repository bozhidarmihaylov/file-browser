//
//  FileSystem.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileSystem {
    var documentsDirectoryUrl: URL { get }
    var temporaryDirectoryUrl: URL { get }
    
    func fileExists(
        atPath path: String
    ) -> Bool
    
    func fileExists(
        atPath path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>
    ) -> Bool
    
    func createDirectory(
        atPath path: String,
        withIntermediateDirectories createIntermediates: Bool
    ) throws
    
    func moveFile(
        at atUrl: URL,
        to toUrl: URL
    ) throws
}

struct FileSystemImpl: FileSystem {
    static let shared: FileSystem = FileSystemImpl()
    
    private var fileManager: FileManager { FileManager.default }
    
    var documentsDirectoryUrl: URL {
        fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }
    
    var temporaryDirectoryUrl: URL {
        fileManager.temporaryDirectory
    }
    
    func fileExists(
        atPath path: String
    ) -> Bool {
        fileManager.fileExists(atPath: path)
    }
    
    func fileExists(
        atPath path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>
    ) -> Bool {
        fileManager.fileExists(
            atPath: path,
            isDirectory: isDirectory
        )
    }
    
    func createDirectory(
        atPath path: String,
        withIntermediateDirectories createIntermediates: Bool
    ) throws {
        try fileManager.createDirectory(
            atPath: path,
            withIntermediateDirectories: createIntermediates
        )
    }
    
    func moveFile(
        at atUrl: URL,
        to toUrl: URL
    ) throws {
        try fileManager.moveItem(at: atUrl, to: toUrl)
    }
}
