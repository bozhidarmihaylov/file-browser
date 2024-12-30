//
//  ApiConfigStoreMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class ApiConfigStoreMock: ApiConfigStore {
    var config: (ApiConfig)?
}
