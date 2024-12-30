//
//  ApiBucketRepositoryFactoryImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

struct ApiBucketRepositoryFactoryImpl: BucketRepositoryFactory {
    func createBucketRepository() throws -> BucketRepository? {
        ApiBucketRepositoryImpl()
    }
}
