//
//  RequestSignerMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class RequestSignerMock: RequestSigner {
    
    private(set) var signRequestWithConfigCall: [(
        request: URLRequest,
        config: ApiConfig
    )] = []
    var signRequestWithConfigOnCall: ((inout URLRequest, ApiConfig) -> Void)? = nil
    func sign(
        request: inout URLRequest,
        with config: ApiConfig
    ) {
        signRequestWithConfigCall.append((
            request: request,
            config: config
        ))
        signRequestWithConfigOnCall?(&request, config)
    }
}
