// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileBrowserViewMock: FileBrowserView {
    var visibleIndexPaths: [IndexPath] = []

    //MARK: - configureCellAccessoryView

    var configureCellAccessoryViewAtWithCallsCount = 0
    var configureCellAccessoryViewAtWithCalled: Bool {
        return configureCellAccessoryViewAtWithCallsCount > 0
    }
    var configureCellAccessoryViewAtWithReceivedArguments: (indexPath: IndexPath, accessoryVm: AccessoryVm)?
    var configureCellAccessoryViewAtWithReceivedInvocations: [(indexPath: IndexPath, accessoryVm: AccessoryVm)] = []
    var configureCellAccessoryViewAtWithClosure: ((IndexPath, AccessoryVm) -> Void)?

    func configureCellAccessoryView(at indexPath: IndexPath, with accessoryVm: AccessoryVm) {
        configureCellAccessoryViewAtWithCallsCount += 1
        configureCellAccessoryViewAtWithReceivedArguments = (indexPath: indexPath, accessoryVm: accessoryVm)
        configureCellAccessoryViewAtWithReceivedInvocations.append((indexPath: indexPath, accessoryVm: accessoryVm))
        configureCellAccessoryViewAtWithClosure?(indexPath, accessoryVm)
    }

    //MARK: - reloadData

    var reloadDataCallsCount = 0
    var reloadDataCalled: Bool {
        return reloadDataCallsCount > 0
    }
    var reloadDataClosure: (() -> Void)?

    func reloadData() {
        reloadDataCallsCount += 1
        reloadDataClosure?()
    }

    //MARK: - insertRows

    var insertRowsAtCountCallsCount = 0
    var insertRowsAtCountCalled: Bool {
        return insertRowsAtCountCallsCount > 0
    }
    var insertRowsAtCountReceivedArguments: (indexPath: IndexPath, count: Int)?
    var insertRowsAtCountReceivedInvocations: [(indexPath: IndexPath, count: Int)] = []
    var insertRowsAtCountClosure: ((IndexPath, Int) -> Void)?

    func insertRows(at indexPath: IndexPath, count: Int) {
        insertRowsAtCountCallsCount += 1
        insertRowsAtCountReceivedArguments = (indexPath: indexPath, count: count)
        insertRowsAtCountReceivedInvocations.append((indexPath: indexPath, count: count))
        insertRowsAtCountClosure?(indexPath, count)
    }

    //MARK: - deselectCell

    var deselectCellAtCallsCount = 0
    var deselectCellAtCalled: Bool {
        return deselectCellAtCallsCount > 0
    }
    var deselectCellAtReceivedIndexPath: IndexPath?
    var deselectCellAtReceivedInvocations: [IndexPath] = []
    var deselectCellAtClosure: ((IndexPath) -> Void)?

    func deselectCell(at indexPath: IndexPath) {
        deselectCellAtCallsCount += 1
        deselectCellAtReceivedIndexPath = indexPath
        deselectCellAtReceivedInvocations.append(indexPath)
        deselectCellAtClosure?(indexPath)
    }

}
