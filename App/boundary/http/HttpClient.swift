//
//  HttpClient.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol HttpClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
