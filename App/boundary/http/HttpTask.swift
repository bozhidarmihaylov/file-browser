//
//  HttpTask.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol HttpTask {
    var identifier: Int { get }
    var currentRequest: URLRequest? { get }
    var progress: Progress { get }
    
    func resume()
}
