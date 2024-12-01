// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileBrowserPresenterMock: FileBrowserPresenter {

    //MARK: - reloadVisibleCellsData

    var reloadVisibleCellsDataCallsCount = 0
    var reloadVisibleCellsDataCalled: Bool {
        return reloadVisibleCellsDataCallsCount > 0
    }
    var reloadVisibleCellsDataClosure: (() -> Void)?

    func reloadVisibleCellsData() {
        reloadVisibleCellsDataCallsCount += 1
        reloadVisibleCellsDataClosure?()
    }

}
