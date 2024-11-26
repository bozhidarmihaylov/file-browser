//
//  DataSubscript.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol DataSubscript {
    subscript(data key: String) -> Data? { get set }
    mutating func remove(_ key: String)
}

extension DataSubscript {
    var codableSubscript: CodableSubscript {
        CodableSubscriptImpl(dataSubscript: self)
    }
}
