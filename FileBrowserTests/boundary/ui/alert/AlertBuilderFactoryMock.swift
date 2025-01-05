//
//  AlertBuilderFactoryMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AlertBuilderFactoryMock: AlertBuilderFactory {
    private(set) var createAlertBuilderCallCount = 0
    
    var createAlertBuilderResult: AlertBuilder! = nil
    func createAlertBuilder() -> AlertBuilder {
        createAlertBuilderCallCount += 1
        
        return createAlertBuilderResult
    }
}
