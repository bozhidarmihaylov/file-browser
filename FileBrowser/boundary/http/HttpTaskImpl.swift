//
//  HttpTaskImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct HttpTaskImpl {
    init(
        underlying: URLSessionTask
    ) {
        self.underlying = underlying
    }
    
    private let underlying: URLSessionTask
}

extension HttpTaskImpl: HttpTask {
    var identifier: Int {
        underlying.taskIdentifier
    }
    
    var currentRequest: URLRequest? {
        underlying.currentRequest
    }
    
    var progress: Progress {
        underlying.progress
    }
    
    func resume() {
        underlying.resume()
    }
}
