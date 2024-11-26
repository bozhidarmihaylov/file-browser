//
//  JsonAdapter.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol JsonAdapter {
    func fromJsonData<T: Decodable>(_ jsonData: Data, type: T.Type) throws -> T
    func toJsonData<T: Encodable>(object: T) throws -> Data
}

struct JsonAdapterImpl: JsonAdapter {
    func fromJsonData<T: Decodable>(_ jsonData: Data, type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: jsonData)
    }
    
    func toJsonData<T>(object: T) throws -> Data where T : Encodable {
        try JSONEncoder().encode(object)
    }
}
