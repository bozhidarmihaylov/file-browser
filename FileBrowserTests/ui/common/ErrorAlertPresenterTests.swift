//
//  ErrorAlertPresenterTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import XCTest
@testable import App

final class ErrorAlertPresenterTests: XCTestCase {
    func testShow_connectivityError_connectivityErrorAlertShown() {
        let (sut, alertBuilderFactoryMock, alertBuilderMock, alertMock) = createSut()
        
        sut.showErrorAlert(
            of: Copy.connectivityError,
            with: Copy.errorMessage,
            on: Copy.node
        )
        
        XCTAssertEqual(alertBuilderFactoryMock.createAlertBuilderCallCount, 1)
        
        XCTAssertEqual(alertBuilderMock.setMessageCalls.count, 1)
        XCTAssertEqual(alertBuilderMock.setMessageCalls.last, Copy.connectivityErrorMessage)
        
        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.count, 1)
        XCTAssertIdentical(alertMock.showOnNodeAnimatedCalls.last?.node as? AnyObject, Copy.node)
        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.last?.animated, true)
    }
    
    func testShow_nonConnectivityError_messageErrorAlertShown() {
        let (sut, alertBuilderFactoryMock, alertBuilderMock, alertMock) = createSut()
        
        sut.showErrorAlert(
            of: Copy.error,
            with: Copy.errorMessage,
            on: Copy.node
        )
        
        XCTAssertEqual(alertBuilderFactoryMock.createAlertBuilderCallCount, 1)
        
        XCTAssertEqual(alertBuilderMock.setMessageCalls.count, 1)
        XCTAssertEqual(alertBuilderMock.setMessageCalls.last, Copy.errorMessage)
        
        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.count, 1)
        XCTAssertIdentical(alertMock.showOnNodeAnimatedCalls.last?.node as? AnyObject, Copy.node)
        XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.last?.animated, true)
    }
    
    func testShow_noNode_noErrorAlertShown() {
        for error: Error in [Copy.error, Copy.connectivityError] {
            let (sut, alertBuilderFactoryMock, alertBuilderMock, alertMock) = createSut()
            
            sut.showErrorAlert(
                of: error,
                with: Copy.errorMessage,
                on: nil
            )
            
            XCTAssertEqual(alertBuilderFactoryMock.createAlertBuilderCallCount, 0)
            XCTAssertEqual(alertBuilderMock.buildCallCount, 0)
            XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.count, 0)
        }
    }
    
    // MARK: Private methods
    
    private func createSut() -> (
        ErrorAlertPresenterImpl,
        AlertBuilderFactoryMock,
        AlertBuilderMock,
        AlertMock
    ) {
        let alertMock = AlertMock()
        
        let alertBuilderMock = AlertBuilderMock()
        alertBuilderMock.buildResult = alertMock
        
        let alertBuilderFactoryMock = AlertBuilderFactoryMock()
        alertBuilderFactoryMock.createAlertBuilderResult = alertBuilderMock
        
        let sut = ErrorAlertPresenterImpl(
            alertBuilderFactory: alertBuilderFactoryMock
        )
        
        return (
            sut,
            alertBuilderFactoryMock,
            alertBuilderMock,
            alertMock
        )
    }
    
    private enum Copy {
        static let error = NSError.mock
        static let errorMessage = "Test error message"
        
        static let connectivityError = NSError(
            domain: NSURLErrorDomain,
            code: 1
        )
        static let connectivityErrorMessage = "Connectivity error"
        
        static let node = NodeMock()
    }
}
