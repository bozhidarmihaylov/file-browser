//
//  ApiConfigStoreMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import FileBrowser

final class ApiConfigStoreMock: ApiConfigStore {
    var config: (ApiConfig)?
}
