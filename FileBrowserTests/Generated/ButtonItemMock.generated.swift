// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class ButtonItemMock: ButtonItem {
    var isHidden: Bool {
        get { return underlyingIsHidden }
        set(value) { underlyingIsHidden = value }
    }
    var underlyingIsHidden: Bool!

}
