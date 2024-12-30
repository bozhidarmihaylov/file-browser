//
//  BucketRepositoryFactory.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository?
}
