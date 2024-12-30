//
//  NSError+mock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

extension NSError {
    static let mock = NSError(domain: "testError", code: 123)
}
