//
//  JsonEncoded.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

@propertyWrapper
struct JsonEncoded<T: Codable> {
    init(
        data: Data
    ) {
        self.data = data
    }
    
    private var data: Data?
    
    var wrappedValue: T? {
        get {
            guard let data else { return nil }
            
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            guard let newValue else {
                data = nil
                return
            }
            data = try? JSONEncoder().encode(newValue)
        }
    }
}
