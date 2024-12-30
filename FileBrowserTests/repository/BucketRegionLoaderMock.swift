//
//  BucketRegionLoaderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class BucketRegionLoaderMock: BucketRegionLoader {
    private(set) var loadRegionWithBucketNameCalls: [String] = []
    
    var loadRegionWithBucketNameResult: String! = nil
    var loadRegionWithBucketNameError: Error? = nil
    func loadRegion(with bucketName: String) async throws -> String {
        loadRegionWithBucketNameCalls.append(bucketName)
        
        if let error = loadRegionWithBucketNameError {
            throw error
        }
        
        return loadRegionWithBucketNameResult
    }
}
