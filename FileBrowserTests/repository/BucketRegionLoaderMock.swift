//
//  BucketRegionLoaderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class BucketRegionLoaderMock: BucketRegionLoader {
    func loadRegion(with bucketName: String) async throws -> String {
        ""
    }
}
