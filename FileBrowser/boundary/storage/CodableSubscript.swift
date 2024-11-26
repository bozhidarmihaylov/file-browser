//
//  CodableSubscript.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol CodableSubscript {
    subscript<T: Codable>(codable key: String) -> T? { get set }
    mutating func remove(_ key: String)
}

struct CodableSubscriptImpl: CodableSubscript {
    init(dataSubscript: DataSubscript) {
        self.dataSubscript = dataSubscript
    }
    
    private var dataSubscript: DataSubscript
    
    subscript<T>(codable key: String) -> T? where T : Decodable, T : Encodable {
        get {
            guard let data = dataSubscript[data: key] else { return nil }
            
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            guard let newValue else {
                remove(key)
                return
            }
            dataSubscript[data: key] = try? JSONEncoder().encode(newValue)
        }
    }
    
    mutating func remove(_ key: String) {
        dataSubscript[data: key] = nil
    }
}
