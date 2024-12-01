//
//  RequestSigner.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol RequestSigner {
    func sign(
        request: inout URLRequest,
        with config: ApiConfig
    )
}
