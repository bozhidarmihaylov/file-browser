//
//  ErrorAlertPresenterMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class ErrorAlertPresenterMock: ErrorAlertPresenter {
    private(set) var showErrorAlertCalls: [(
        error: Error,
        message: String,
        node: Node?
    )] = []
    
    func showErrorAlert(
        of error: Error,
        with message: String,
        on node: Node?
    ) {
        showErrorAlertCalls.append((
            error: error,
            message: message,
            node: node
        ))
    }
}
