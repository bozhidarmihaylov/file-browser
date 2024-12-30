//
//  XmlDecoderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class XmlDecoderMock: XmlDecoder {
    
    private(set) var fromXmlDataCalls: [(
        data: Data,
        type: Any.Type
    )] = []
    
    var fromXmlDataResult: Any! = nil
    var fromXmlDataError: Error? = nil
    func fromXmlData<T: Decodable>(
        _ xmlData: Data,
        type: T.Type
    ) throws -> T {
        fromXmlDataCalls.append((xmlData, type))
        
        if let error = fromXmlDataError {
            throw error
        }
        
        return fromXmlDataResult as! T
    }
}
