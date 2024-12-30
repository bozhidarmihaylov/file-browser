//
//  FileDownloadRequestFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol FileDownloadRequestFactory {
    func createDownloadRequest(
        filePath: String,
        with config: ApiConfig
    ) -> URLRequest
}

struct FileDownloadRequestFactoryImpl: FileDownloadRequestFactory {
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
        components.path = filePath.starts(with: "/") 
            ? filePath
            : "/" + filePath
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        
        requestSigner.sign(request: &request, with: config)
        
        return request
    }
}
