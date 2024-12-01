// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class SyncPerformerMock: SyncPerformer {

    //MARK: - sync<T>

    var syncCallsCount = 0
    var syncCalled: Bool {
        return syncCallsCount > 0
    }
    var syncReceivedClosure: (() throws -> T)?
    var syncReceivedInvocations: [(() throws -> T)] = []
    var syncReturnValue: T!
    var syncClosure: ((() throws -> T) -> T)?

    func sync<T>(_ closure: () throws -> T) -> T {
        syncCallsCount += 1
        syncReceivedClosure = closure
        syncReceivedInvocations.append(closure)
        return syncClosure.map({ $0(closure) }) ?? syncReturnValue
    }

}
