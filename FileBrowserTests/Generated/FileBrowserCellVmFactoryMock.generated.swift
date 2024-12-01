// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileBrowserCellVmFactoryMock: FileBrowserCellVmFactory {

    //MARK: - createVm

    var createVmEntryCallsCount = 0
    var createVmEntryCalled: Bool {
        return createVmEntryCallsCount > 0
    }
    var createVmEntryReceivedEntry: Entry?
    var createVmEntryReceivedInvocations: [Entry] = []
    var createVmEntryReturnValue: EntryCellVm!
    var createVmEntryClosure: ((Entry) -> EntryCellVm)?

    func createVm(entry: Entry) -> EntryCellVm {
        createVmEntryCallsCount += 1
        createVmEntryReceivedEntry = entry
        createVmEntryReceivedInvocations.append(entry)
        return createVmEntryClosure.map({ $0(entry) }) ?? createVmEntryReturnValue
    }

    //MARK: - createVm

    var createVmEntriesCallsCount = 0
    var createVmEntriesCalled: Bool {
        return createVmEntriesCallsCount > 0
    }
    var createVmEntriesReceivedEntries: [Entry]?
    var createVmEntriesReceivedInvocations: [[Entry]] = []
    var createVmEntriesReturnValue: [EntryCellVm]!
    var createVmEntriesClosure: (([Entry]) -> [EntryCellVm])?

    func createVm(entries: [Entry]) -> [EntryCellVm] {
        createVmEntriesCallsCount += 1
        createVmEntriesReceivedEntries = entries
        createVmEntriesReceivedInvocations.append(entries)
        return createVmEntriesClosure.map({ $0(entries) }) ?? createVmEntriesReturnValue
    }

}
