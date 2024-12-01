// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class HudPresenterMock: HudPresenter {

    //MARK: - setShown

    var setShownOnCallsCount = 0
    var setShownOnCalled: Bool {
        return setShownOnCallsCount > 0
    }
    var setShownOnReceivedArguments: (shown: Bool, view: View)?
    var setShownOnReceivedInvocations: [(shown: Bool, view: View)] = []
    var setShownOnClosure: ((Bool, View) -> Void)?

    func setShown(_ shown: Bool, on view: View) {
        setShownOnCallsCount += 1
        setShownOnReceivedArguments = (shown: shown, view: view)
        setShownOnReceivedInvocations.append((shown: shown, view: view))
        setShownOnClosure?(shown, view)
    }

}
