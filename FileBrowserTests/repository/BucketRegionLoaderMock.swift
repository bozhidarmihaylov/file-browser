//
//  BucketRegionLoaderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import FileBrowser

final class BucketRegionLoaderMock: BucketRegionLoader {
    func loadRegion(with bucketName: String) async throws -> String {
        ""
    }
}
