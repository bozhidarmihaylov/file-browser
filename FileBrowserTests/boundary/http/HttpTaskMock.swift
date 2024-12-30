//
//  HttpTaskMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class HttpTaskMock: HttpTask {
    init(
        identifier: Int! = nil
    ) {
        _identifier = identifier
    }
    
    private var _identifier: Int! = nil
    var identifier: Int {
        get { _identifier }
        set { _identifier = newValue }
    }
    
    var currentRequest: URLRequest?
    
    private var _progress: Progress! = nil
    var progress: Progress {
        get { _progress }
        set { _progress = newValue }
    }
    
    private(set) var resumeCallCount: Int = 0
    var resumeOnCall: (() -> Void)? = nil
    func resume() {
        resumeCallCount += 1
        
        resumeOnCall?()
    }
}
