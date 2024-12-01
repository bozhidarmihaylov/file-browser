//
//  XmlDecoderImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import XMLCoder


struct XmlDecoderImpl: XmlDecoder {
    static let shared: XmlDecoder = XmlDecoderImpl()
    
    init(
        xmlDecoder: XMLDecoder = createXmlDecoder()
    ) {
        self.xmlDecoder = xmlDecoder
    }
    
    private let xmlDecoder: XMLDecoder
        
    func fromXmlData<T: Decodable>(_ xmlData: Data, type: T.Type) throws -> T {
        try xmlDecoder.decode(T.self, from: xmlData)
    }
}

extension XmlDecoderImpl {
    private static func createXmlDecoder() -> XMLDecoder {
       let xmlDecoder = XMLDecoder()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        
        xmlDecoder.dateDecodingStrategy = .formatted(formatter)

        return xmlDecoder
    }
}
