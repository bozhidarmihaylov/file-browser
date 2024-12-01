// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class ApiCredentialMock: ApiCredential {
    var accessKey: String {
        get { return underlyingAccessKey }
        set(value) { underlyingAccessKey = value }
    }
    var underlyingAccessKey: String!
    var secretKey: String {
        get { return underlyingSecretKey }
        set(value) { underlyingSecretKey = value }
    }
    var underlyingSecretKey: String!

}
