//
//  S3Factory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol S3Factory {
    func createS3(config: ApiConfig) throws -> S3
}
