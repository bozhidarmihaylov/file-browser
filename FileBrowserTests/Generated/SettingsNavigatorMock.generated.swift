// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class SettingsNavigatorMock: SettingsNavigator {

    //MARK: - goForward

    var goForwardCallsCount = 0
    var goForwardCalled: Bool {
        return goForwardCallsCount > 0
    }
    var goForwardClosure: (() -> Void)?

    func goForward() {
        goForwardCallsCount += 1
        goForwardClosure?()
    }

    //MARK: - goBack

    var goBackCallsCount = 0
    var goBackCalled: Bool {
        return goBackCallsCount > 0
    }
    var goBackClosure: (() -> Void)?

    func goBack() {
        goBackCallsCount += 1
        goBackClosure?()
    }

}
