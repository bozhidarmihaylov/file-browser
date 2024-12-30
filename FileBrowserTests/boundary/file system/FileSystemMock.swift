//
//  FileSystemMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileSystemMock: FileSystem {
    var temporaryDirectoryUrl: URL = URL(string: "http://abv.bg/")!
    
    func moveFile(at atUrl: URL, to toUrl: URL) throws {
        
    }
    
    var documentsDirectoryUrl: URL = URL(string: "http://dir.bg/")!
    
    func fileExists(atPath path: String) -> Bool {
        false
    }
    
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool {
        false
    }
    
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {
        
    }
}
