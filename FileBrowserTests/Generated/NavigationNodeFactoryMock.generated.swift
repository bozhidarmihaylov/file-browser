// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import FileBrowser

class NavigationNodeFactoryMock: NavigationNodeFactory {

    //MARK: - createFileBrowserNode

    var createFileBrowserNodeNamePathCallsCount = 0
    var createFileBrowserNodeNamePathCalled: Bool {
        return createFileBrowserNodeNamePathCallsCount > 0
    }
    var createFileBrowserNodeNamePathReceivedArguments: (name: String, path: String)?
    var createFileBrowserNodeNamePathReceivedInvocations: [(name: String, path: String)] = []
    var createFileBrowserNodeNamePathReturnValue: UIViewController!
    var createFileBrowserNodeNamePathClosure: ((String, String) -> UIViewController)?

    func createFileBrowserNode(name: String, path: String) -> UIViewController {
        createFileBrowserNodeNamePathCallsCount += 1
        createFileBrowserNodeNamePathReceivedArguments = (name: name, path: path)
        createFileBrowserNodeNamePathReceivedInvocations.append((name: name, path: path))
        return createFileBrowserNodeNamePathClosure.map({ $0(name, path) }) ?? createFileBrowserNodeNamePathReturnValue
    }

    //MARK: - createSettingsNode

    var createSettingsNodeCallsCount = 0
    var createSettingsNodeCalled: Bool {
        return createSettingsNodeCallsCount > 0
    }
    var createSettingsNodeReturnValue: UIViewController!
    var createSettingsNodeClosure: (() -> UIViewController)?

    func createSettingsNode() -> UIViewController {
        createSettingsNodeCallsCount += 1
        return createSettingsNodeClosure.map({ $0() }) ?? createSettingsNodeReturnValue
    }

}
