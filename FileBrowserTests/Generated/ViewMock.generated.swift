// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class ViewMock: View {
    var tag: Int {
        get { return underlyingTag }
        set(value) { underlyingTag = value }
    }
    var underlyingTag: Int!
    var isHidden: Bool {
        get { return underlyingIsHidden }
        set(value) { underlyingIsHidden = value }
    }
    var underlyingIsHidden: Bool!
    var isUserInteractionEnabled: Bool {
        get { return underlyingIsUserInteractionEnabled }
        set(value) { underlyingIsUserInteractionEnabled = value }
    }
    var underlyingIsUserInteractionEnabled: Bool!

}
