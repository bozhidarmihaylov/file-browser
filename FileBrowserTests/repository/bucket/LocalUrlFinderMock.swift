//
//  LocalUrlFinderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class LocalUrlFinderMock: LocalUrlFinder {
    private(set) var localUrlForRelativeFilePathAndBucketNameCalls: [(
        relativeFilePath: String,
        bucketName: String
    )] = []
    var localUrlForRelativeFilePathAndBucketNameResult: URL! = nil
    var localUrlForRelativeFilePathAndBucketNameClosure: ((String, String) -> URL)? = nil
    func localUrl(for relativeFilePath: String, in bucketName: String) -> URL {
        localUrlForRelativeFilePathAndBucketNameCalls.append((
            relativeFilePath: relativeFilePath,
            bucketName: bucketName
        ))
        
        return localUrlForRelativeFilePathAndBucketNameClosure?(relativeFilePath, bucketName) ?? localUrlForRelativeFilePathAndBucketNameResult
    }
}
