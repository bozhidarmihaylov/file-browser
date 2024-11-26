//
//  HttpClient.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol HttpClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct HttpClientImpl: HttpClient {
    init(session: URLSession) {
        self.session = session
    }
    
    private let session: URLSession
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
    
    static let shared: HttpClient = HttpClientImpl(session: .shared)
}

