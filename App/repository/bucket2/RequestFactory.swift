//
//  RequestFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov on 24.12.24.
//

import Foundation

protocol RequestFactory {
    func createDownloadRequest(
        filePath: String,
        with config: ApiConfig
    ) -> URLRequest
    
    func createListRequest(
        folderPath: String,
        continuationToken: String?,
        pageSize: Int,
        with config: ApiConfig
    ) -> URLRequest
}

struct RequestFactoryImpl: RequestFactory {
    init(
        requestSigner: RequestSigner = RequestSignerImpl()
    ) {
        self.requestSigner = requestSigner
    }
    
    private let requestSigner: RequestSigner
    
    func createDownloadRequest(
        filePath: String,
        with config: ApiConfig
    ) -> URLRequest {
        let bucket = config.bucket
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(bucket.name).s3.\(bucket.region).amazonaws.com"
        components.path = filePath
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        
        requestSigner.sign(request: &request, with: config)
        
        return request
    }
    
    func createListRequest(
        folderPath: String,
        continuationToken: String?,
        pageSize: Int,
        with config: ApiConfig
    ) -> URLRequest {
        let bucket = config.bucket
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(bucket.name).s3.\(bucket.region).amazonaws.com"
        components.path = "/"
     
        components.queryItems = [
            URLQueryItem(
                name: "list-type",
                value: "2"
            ),
            URLQueryItem(
                name: "continuation-token",
                value: continuationToken
            ),
            URLQueryItem(
                name: "delimiter",
                value: "/"
            ),
            URLQueryItem(
                name: "prefix",
                value: folderPath
            ),
            URLQueryItem(
                name: "max-keys",
                value: pageSize.description
            )
        ].filter { $0.value != nil }
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        
        requestSigner.sign(request: &request, with: config)
        
        return request
    }
}
