//
//  BucketRepositoryFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository?
}
