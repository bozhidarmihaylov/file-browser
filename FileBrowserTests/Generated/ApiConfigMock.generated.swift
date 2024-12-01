// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class ApiConfigMock: ApiConfig {
    var bucket: Bucket {
        get { return underlyingBucket }
        set(value) { underlyingBucket = value }
    }
    var underlyingBucket: Bucket!
    var credential: ApiCredential {
        get { return underlyingCredential }
        set(value) { underlyingCredential = value }
    }
    var underlyingCredential: ApiCredential!

}
