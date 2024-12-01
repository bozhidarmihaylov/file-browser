// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class BucketMock: Bucket {
    var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    var underlyingName: String!
    var region: String {
        get { return underlyingRegion }
        set(value) { underlyingRegion = value }
    }
    var underlyingRegion: String!

}
