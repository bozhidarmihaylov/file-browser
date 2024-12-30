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
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataForRequestCalls.append(request)
        
        if let error = dataForRequestThrownError {
            throw error
        }        
        return dataForRequestResult!
    }
    
    private var dataForRequestResult: (Data, URLResponse)? = nil
    func dataForRequestSuccess(result: (Data, URLResponse)) {
        dataForRequestResult = result
    }
    
    private var dataForRequestThrownError: Error? = nil
    func dataForRequestThrows(_ error: Error) {
        dataForRequestThrownError = error
    }
}
