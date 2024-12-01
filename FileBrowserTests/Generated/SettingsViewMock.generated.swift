// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class SettingsViewMock: SettingsView {
    var rootView: View {
        get { return underlyingRootView }
        set(value) { underlyingRootView = value }
    }
    var underlyingRootView: View!
    var accessKeyTextField: TextField {
        get { return underlyingAccessKeyTextField }
        set(value) { underlyingAccessKeyTextField = value }
    }
    var underlyingAccessKeyTextField: TextField!
    var secretKeyTextField: TextField {
        get { return underlyingSecretKeyTextField }
        set(value) { underlyingSecretKeyTextField = value }
    }
    var underlyingSecretKeyTextField: TextField!
    var bucketNameTextField: TextField {
        get { return underlyingBucketNameTextField }
        set(value) { underlyingBucketNameTextField = value }
    }
    var underlyingBucketNameTextField: TextField!
    var saveButton: Button {
        get { return underlyingSaveButton }
        set(value) { underlyingSaveButton = value }
    }
    var underlyingSaveButton: Button!
    var logoutButtonItem: ButtonItem {
        get { return underlyingLogoutButtonItem }
        set(value) { underlyingLogoutButtonItem = value }
    }
    var underlyingLogoutButtonItem: ButtonItem!
    var backButtonItem: ButtonItem {
        get { return underlyingBackButtonItem }
        set(value) { underlyingBackButtonItem = value }
    }
    var underlyingBackButtonItem: ButtonItem!

    //MARK: - setTopBarButtonsVisible

    var setTopBarButtonsVisibleCallsCount = 0
    var setTopBarButtonsVisibleCalled: Bool {
        return setTopBarButtonsVisibleCallsCount > 0
    }
    var setTopBarButtonsVisibleReceivedVisible: Bool?
    var setTopBarButtonsVisibleReceivedInvocations: [Bool] = []
    var setTopBarButtonsVisibleClosure: ((Bool) -> Void)?

    func setTopBarButtonsVisible(_ visible: Bool) {
        setTopBarButtonsVisibleCallsCount += 1
        setTopBarButtonsVisibleReceivedVisible = visible
        setTopBarButtonsVisibleReceivedInvocations.append(visible)
        setTopBarButtonsVisibleClosure?(visible)
    }

}
