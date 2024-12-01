// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class DataSubscriptMock: DataSubscript {

    //MARK: - remove

    var removeCallsCount = 0
    var removeCalled: Bool {
        return removeCallsCount > 0
    }
    var removeReceivedKey: String?
    var removeReceivedInvocations: [String] = []
    var removeClosure: ((String) -> Void)?

    func remove(_ key: String) {
        removeCallsCount += 1
        removeReceivedKey = key
        removeReceivedInvocations.append(key)
        removeClosure?(key)
    }

}
