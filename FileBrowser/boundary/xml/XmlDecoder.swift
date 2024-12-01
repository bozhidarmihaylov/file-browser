//
//  XmlDecoder.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol XmlDecoder {
    func fromXmlData<T: Decodable>(_ xmlData: Data, type: T.Type) throws -> T
}
