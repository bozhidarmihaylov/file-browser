// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class TextFieldMock: TextField {
    var text: String?
    var isSecureTextEntry: Bool {
        get { return underlyingIsSecureTextEntry }
        set(value) { underlyingIsSecureTextEntry = value }
    }
    var underlyingIsSecureTextEntry: Bool!
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

    //MARK: - becomeFirstResponder

    var becomeFirstResponderCallsCount = 0
    var becomeFirstResponderCalled: Bool {
        return becomeFirstResponderCallsCount > 0
    }
    var becomeFirstResponderReturnValue: Bool!
    var becomeFirstResponderClosure: (() -> Bool)?

    func becomeFirstResponder() -> Bool {
        becomeFirstResponderCallsCount += 1
        return becomeFirstResponderClosure.map({ $0() }) ?? becomeFirstResponderReturnValue
    }

}
