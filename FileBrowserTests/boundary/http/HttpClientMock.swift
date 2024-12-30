//
//  HttpClientMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class HttpClientMock: HttpClient {
    
    private(set) var dataForRequestCalls: [URLRequest] = []
    
    var dataForRequestResult: (Data, URLResponse)! = nil
    var dataForRequestError: Error? = nil
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataForRequestCalls.append(request)
        
        if let error = dataForRequestError {
            throw error
        }        
        return dataForRequestResult
    }
}
