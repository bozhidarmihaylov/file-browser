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
