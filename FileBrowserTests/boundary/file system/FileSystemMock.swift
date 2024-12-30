//
//  FileSystemMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class FileSystemMock: FileSystem {
    
    var temporaryDirectoryUrlResult: URL! = nil
    var temporaryDirectoryUrl: URL { temporaryDirectoryUrlResult }
    
    private(set) var moveFileAtUrlToUrlCalls: [(
        atUrl: URL,
        toUrl: URL
    )] = []
    
    var moveFileAtUrlToUrlError: Error? = nil
    func moveFile(at atUrl: URL, to toUrl: URL) throws {
        moveFileAtUrlToUrlCalls.append((
            atUrl: atUrl,
            toUrl: toUrl
        ))
        
        if let error = moveFileAtUrlToUrlError {
            throw error
        }
    }
    
    var documentsDirectoryUrlResult: URL! = nil
    var documentsDirectoryUrl: URL { documentsDirectoryUrlResult }
    
    private(set) var fileExistsAtPathCalls: [String] = []
    var fileExistsAtPathResult: Bool! = nil
    var fileExistsAtPathClosure: ((String) -> Bool)? = nil
    func fileExists(atPath path: String) -> Bool {
        fileExistsAtPathCalls.append(path)
        
        return fileExistsAtPathClosure?(path) ?? fileExistsAtPathResult
    }
    
    private(set) var fileExistsAtPathIsDirectoryCalls: [(
        path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>
    )] = []
    var fileExistsAtPathIsDirectoryResult: ((UnsafeMutablePointer<ObjCBool>) -> Bool)! = nil
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool {
        fileExistsAtPathIsDirectoryCalls.append((
            path: path,
            isDirectory: isDirectory
        ))
        
        return fileExistsAtPathIsDirectoryResult(isDirectory)
    }
    
    private(set) var createDirectoryAtPathWithIntermeidateDirectoriesCalls: [(
        path: String,
        createIntermediates: Bool
    )] = []
    var createDirectoryAtPathWithIntermeidateDirectoriesError: Error? = nil
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {
        createDirectoryAtPathWithIntermeidateDirectoriesCalls.append((
            path: path,
            createIntermediates: createIntermediates
        ))
        
        if let error = createDirectoryAtPathWithIntermeidateDirectoriesError {
            throw error
        }
    }
}
