//
//  CancelllableMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

@testable import App

final class CancelllableMock: Cancellable {
    private(set) var cancelCallsCount: Int = 0
    func cancel() {
        cancelCallsCount += 1
    }
}
