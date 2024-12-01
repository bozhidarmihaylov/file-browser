// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileBrowserControllerMock: FileBrowserController {

    //MARK: - cellCount

    var cellCountCallsCount = 0
    var cellCountCalled: Bool {
        return cellCountCallsCount > 0
    }
    var cellCountReturnValue: Int!
    var cellCountClosure: (() -> Int)?

    func cellCount() -> Int {
        cellCountCallsCount += 1
        return cellCountClosure.map({ $0() }) ?? cellCountReturnValue
    }

    //MARK: - cellVm

    var cellVmAtCallsCount = 0
    var cellVmAtCalled: Bool {
        return cellVmAtCallsCount > 0
    }
    var cellVmAtReceivedIndexPath: IndexPath?
    var cellVmAtReceivedInvocations: [IndexPath] = []
    var cellVmAtReturnValue: EntryCellVm!
    var cellVmAtClosure: ((IndexPath) -> EntryCellVm)?

    func cellVm(at indexPath: IndexPath) -> EntryCellVm {
        cellVmAtCallsCount += 1
        cellVmAtReceivedIndexPath = indexPath
        cellVmAtReceivedInvocations.append(indexPath)
        return cellVmAtClosure.map({ $0(indexPath) }) ?? cellVmAtReturnValue
    }

    //MARK: - cellAccessoryVm

    var cellAccessoryVmAtCallsCount = 0
    var cellAccessoryVmAtCalled: Bool {
        return cellAccessoryVmAtCallsCount > 0
    }
    var cellAccessoryVmAtReceivedIndexpath: IndexPath?
    var cellAccessoryVmAtReceivedInvocations: [IndexPath] = []
    var cellAccessoryVmAtReturnValue: AccessoryVm!
    var cellAccessoryVmAtClosure: ((IndexPath) -> AccessoryVm)?

    func cellAccessoryVm(at indexpath: IndexPath) -> AccessoryVm {
        cellAccessoryVmAtCallsCount += 1
        cellAccessoryVmAtReceivedIndexpath = indexpath
        cellAccessoryVmAtReceivedInvocations.append(indexpath)
        return cellAccessoryVmAtClosure.map({ $0(indexpath) }) ?? cellAccessoryVmAtReturnValue
    }

    //MARK: - onInit

    var onInitCallsCount = 0
    var onInitCalled: Bool {
        return onInitCallsCount > 0
    }
    var onInitClosure: (() -> Void)?

    func onInit() {
        onInitCallsCount += 1
        onInitClosure?()
    }

    //MARK: - onDeinit

    var onDeinitCallsCount = 0
    var onDeinitCalled: Bool {
        return onDeinitCallsCount > 0
    }
    var onDeinitClosure: (() -> Void)?

    func onDeinit() {
        onDeinitCallsCount += 1
        onDeinitClosure?()
    }

    //MARK: - onViewLoaded

    var onViewLoadedCallsCount = 0
    var onViewLoadedCalled: Bool {
        return onViewLoadedCallsCount > 0
    }
    var onViewLoadedClosure: (() -> Void)?

    func onViewLoaded() {
        onViewLoadedCallsCount += 1
        onViewLoadedClosure?()
    }

    //MARK: - onViewAppeared

    var onViewAppearedCallsCount = 0
    var onViewAppearedCalled: Bool {
        return onViewAppearedCallsCount > 0
    }
    var onViewAppearedClosure: (() -> Void)?

    func onViewAppeared() {
        onViewAppearedCallsCount += 1
        onViewAppearedClosure?()
    }

    //MARK: - onRightButtonItemTap

    var onRightButtonItemTapCallsCount = 0
    var onRightButtonItemTapCalled: Bool {
        return onRightButtonItemTapCallsCount > 0
    }
    var onRightButtonItemTapClosure: (() -> Void)?

    func onRightButtonItemTap() {
        onRightButtonItemTapCallsCount += 1
        onRightButtonItemTapClosure?()
    }

    //MARK: - onCellTap

    var onCellTapAtCallsCount = 0
    var onCellTapAtCalled: Bool {
        return onCellTapAtCallsCount > 0
    }
    var onCellTapAtReceivedIndexPath: IndexPath?
    var onCellTapAtReceivedInvocations: [IndexPath] = []
    var onCellTapAtClosure: ((IndexPath) -> Void)?

    func onCellTap(at indexPath: IndexPath) {
        onCellTapAtCallsCount += 1
        onCellTapAtReceivedIndexPath = indexPath
        onCellTapAtReceivedInvocations.append(indexPath)
        onCellTapAtClosure?(indexPath)
    }

    //MARK: - onCellAccessoryTap

    var onCellAccessoryTapAtCallsCount = 0
    var onCellAccessoryTapAtCalled: Bool {
        return onCellAccessoryTapAtCallsCount > 0
    }
    var onCellAccessoryTapAtReceivedIndexPath: IndexPath?
    var onCellAccessoryTapAtReceivedInvocations: [IndexPath] = []
    var onCellAccessoryTapAtClosure: ((IndexPath) -> Void)?

    func onCellAccessoryTap(at indexPath: IndexPath) {
        onCellAccessoryTapAtCallsCount += 1
        onCellAccessoryTapAtReceivedIndexPath = indexPath
        onCellAccessoryTapAtReceivedInvocations.append(indexPath)
        onCellAccessoryTapAtClosure?(indexPath)
    }

    //MARK: - shouldHighlightRow

    var shouldHighlightRowAtCallsCount = 0
    var shouldHighlightRowAtCalled: Bool {
        return shouldHighlightRowAtCallsCount > 0
    }
    var shouldHighlightRowAtReceivedIndexPath: IndexPath?
    var shouldHighlightRowAtReceivedInvocations: [IndexPath] = []
    var shouldHighlightRowAtReturnValue: Bool!
    var shouldHighlightRowAtClosure: ((IndexPath) -> Bool)?

    func shouldHighlightRow(at indexPath: IndexPath) -> Bool {
        shouldHighlightRowAtCallsCount += 1
        shouldHighlightRowAtReceivedIndexPath = indexPath
        shouldHighlightRowAtReceivedInvocations.append(indexPath)
        return shouldHighlightRowAtClosure.map({ $0(indexPath) }) ?? shouldHighlightRowAtReturnValue
    }

    //MARK: - willDisplayCell

    var willDisplayCellAtCallsCount = 0
    var willDisplayCellAtCalled: Bool {
        return willDisplayCellAtCallsCount > 0
    }
    var willDisplayCellAtReceivedIndexPath: IndexPath?
    var willDisplayCellAtReceivedInvocations: [IndexPath] = []
    var willDisplayCellAtClosure: ((IndexPath) -> Void)?

    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellAtCallsCount += 1
        willDisplayCellAtReceivedIndexPath = indexPath
        willDisplayCellAtReceivedInvocations.append(indexPath)
        willDisplayCellAtClosure?(indexPath)
    }

}
