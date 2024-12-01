// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class FileBrowserNavigatorMock: FileBrowserNavigator {

    //MARK: - goToFile

    var goToFileCallsCount = 0
    var goToFileCalled: Bool {
        return goToFileCallsCount > 0
    }
    var goToFileReceivedFile: Entry?
    var goToFileReceivedInvocations: [Entry] = []
    var goToFileClosure: ((Entry) -> Void)?

    func goToFile(_ file: Entry) {
        goToFileCallsCount += 1
        goToFileReceivedFile = file
        goToFileReceivedInvocations.append(file)
        goToFileClosure?(file)
    }

    //MARK: - goToFolder

    var goToFolderCallsCount = 0
    var goToFolderCalled: Bool {
        return goToFolderCallsCount > 0
    }
    var goToFolderReceivedFolder: Entry?
    var goToFolderReceivedInvocations: [Entry] = []
    var goToFolderClosure: ((Entry) -> Void)?

    func goToFolder(_ folder: Entry) {
        goToFolderCallsCount += 1
        goToFolderReceivedFolder = folder
        goToFolderReceivedInvocations.append(folder)
        goToFolderClosure?(folder)
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

}
