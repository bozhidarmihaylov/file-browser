//
//  SettingsControllerTests.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation

import XCTest
@testable import App

final class SettingsControllerTests: XCTestCase {
    
    // MARK: canSave()
    
    func testCanSave_someFieldIsEmpty_false() {
        for code in 0..<7 {
            let (sut, _, _, _, _, _, _, _, _) = createSut(
                accessKeyEntered: code & 1 != 0,
                secretKeyEntered: code & 2 != 0,
                bucketNameEntered: code & 4 != 0
            )
            
            let result = sut.canSave()
            
            XCTAssertFalse(result)
        }
    }
    
    func testCanSave_allFieldsEntered_true() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.canSave()
        
        XCTAssertTrue(result)
    }
    
    // MARK: accessKey()
    
    func testAccessKey_called_textFieldValueReturned() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.accessKey()
        
        XCTAssertEqual(result, viewMock.accessKeyTextField.text)
    }
    
    // MARK: secretKey()
    
    func testSecretKey_called_textFieldValueReturned() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.secretKey()
        
        XCTAssertEqual(result, viewMock.secretKeyTextField.text)
    }
    
    // MARK: bucketName()
    
    func testBucketName_called_textFieldValueReturned() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.bucketName()
        
        XCTAssertEqual(result, viewMock.bucketNameTextField.text)
    }
    
    // MARK: saveDidStart()
    
    func testSaveDidStart_called_hudOnRootViewIsShown() {
        let (sut, _, _, hudPresenterMock, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.saveDidStart()
        
        XCTAssertEqual(hudPresenterMock.setShownOnViewCalls.count, 1)
        XCTAssertEqual(hudPresenterMock.setShownOnViewCalls.last?.shown, true)
        XCTAssertIdentical(hudPresenterMock.setShownOnViewCalls.last?.view, viewMock.rootView)
    }
    
    // MARK: saveDidFinish(with:)
    
    func testSaveDidFinish_called_hudFromRootViewIsHidden() {
        for result: Result<Void, Error> in [.success(()), .failure(NSError.mock)] {
            let (sut, _, _, hudPresenterMock, _, _, _, _, viewMock) = createSut()
            _ = viewMock
            
            sut.saveDidFinish(with: result)
            
            XCTAssertEqual(hudPresenterMock.setShownOnViewCalls.count, 1)
            XCTAssertEqual(hudPresenterMock.setShownOnViewCalls.last?.shown, false)
            XCTAssertIdentical(hudPresenterMock.setShownOnViewCalls.last?.view, viewMock.rootView)

        }
    }
    
    func testSaveDidFinish_success_forwardNavigated() {
        let (sut, navigatorMock, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.saveDidFinish(with: .success(()))
        
        XCTAssertEqual(navigatorMock.goForwardCallCount, 1)
    }
    
    func testSaveDidFinish_failure_errorAlertShown() {
        for isConnectivityError in [false, true] {
            let (sut, _, _, _, _, alertBuilderFactoryMock, alertBuilderMock, alertMock, viewMock) = createSut()
            _ = viewMock
            
            let error = isConnectivityError ? Copy.connectivityError : NSError.mock
            let errorMessage = isConnectivityError ? Copy.connectivityErrorMessage : Copy.saveAlertErrorMessage
            
            sut.saveDidFinish(with: .failure(error))
            
            XCTAssertEqual(alertBuilderFactoryMock.createAlertBuilderCallCount, 1)
            XCTAssertEqual(alertBuilderMock.setMessageCalls.count, 1)
            XCTAssertEqual(alertBuilderMock.setMessageCalls.last, errorMessage)
            
            XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.count, 1)
            XCTAssertIdentical(alertMock.showOnNodeAnimatedCalls.last?.node as? AnyObject, viewMock.node as? AnyObject)
            XCTAssertEqual(alertMock.showOnNodeAnimatedCalls.last?.animated, true)
        }
    }
    
    // MARK: onViewLoaded()
    
    func testSaveDidFinish_called_accessSecretBucketNameTagOrderSet() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            shouldSetTags: false
        )
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.accessKeyTextField.tag, 0)
        XCTAssertEqual(viewMock.secretKeyTextField.tag, 1)
        XCTAssertEqual(viewMock.bucketNameTextField.tag, 2)
    }
    
    func testSaveDidFinish_called_secretKeyFieldSetForSecureEntry() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.accessKeyTextField.isSecureTextEntry, false)
        XCTAssertEqual(viewMock.secretKeyTextField.isSecureTextEntry, true)
        XCTAssertEqual(viewMock.bucketNameTextField.isSecureTextEntry, false)
    }
    
    func testSaveDidFinish_initialConfigIsSet_fieldsUpdatedFromConfig() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.accessKeyTextField.text, Copy.config.credential.accessKey)
        XCTAssertEqual(viewMock.secretKeyTextField.text, Copy.config.credential.secretKey)
        XCTAssertEqual(viewMock.bucketNameTextField.text, Copy.config.bucket.name)
    }
    
    func testSaveDidFinish_initialConfigIsSet_barButtonsAreShown() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.logoutButtonItem.isHidden, false)
        XCTAssertEqual(viewMock.backButtonItem.isHidden, false)
    }
    
    func testSaveDidFinish_noInitialConfigIsSet_barButtonsAreHidden() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.logoutButtonItem.isHidden, true)
        XCTAssertEqual(viewMock.backButtonItem.isHidden, true)
    }
    
    func testSaveDidFinish_initialConfigIsSet_saveButtonIsEnabled() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.saveButton.isEnabled, true)
    }
    
    func testSaveDidFinish_initialConfigIsSet_saveButtonIsDisabled() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.onViewLoaded()
        
        XCTAssertEqual(viewMock.saveButton.isEnabled, false)
    }
    
    // MARK: onEditingChanged(at:)
    
    func testOnEditingChanged_called_saveButtonStateSynced() {
        for code in 0..<7 {
            let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
                accessKeyEntered: code & 1 != 0,
                secretKeyEntered: code & 2 != 0,
                bucketNameEntered: code & 4 != 0
            )
            _ = viewMock
            
            for field in [viewMock.accessKeyTextField, viewMock.secretKeyTextField, viewMock.bucketNameTextField] {
                sut.onEditingChanged(at: field!)
                
                XCTAssertEqual(viewMock.saveButton.isEnabled, code == 7)
            }
        }
    }
    
    // MARK: onSave()
    
    func testOnSave_called_savePerformed() {
        let (sut, _, _, _, saverMock, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.onSave()
        
        XCTAssertEqual(saverMock.saveCallCount, 1)
    }
    
    // MARK: textFieldShouldReturn(at:)
    
    func testFieldShouldReturn_bucketNameField_savePerformed() {
        let (sut, _, _, _, saverMock, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.textFieldShouldReturn(at: viewMock.bucketNameTextField)
        
        XCTAssertEqual(saverMock.saveCallCount, 1)
        XCTAssertEqual(result, true)
    }
    
    func testFieldShouldReturn_invalidTagField_trueReturned() {
        let (sut, _, _, _, saverMock, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        viewMock.secretKeyTextField.tag = 5
        let result = sut.textFieldShouldReturn(at: viewMock.secretKeyTextField)
        
        XCTAssertEqual(saverMock.saveCallCount, 0)
        XCTAssertEqual(result, true)
    }
    
    func testFieldShouldReturn_accessKeyFeild_secretKeyFieldFocussed() {
        let (sut, _, _, _, saverMock, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.textFieldShouldReturn(at: viewMock.accessKeyTextField)
        
        XCTAssertEqual(saverMock.saveCallCount, 0)
        XCTAssertEqual((viewMock.secretKeyTextField as? TextFieldMock)?.becomeFirstResponderCallCount, 1)
        XCTAssertEqual(result, false)
    }
    
    func testFieldShouldReturn_secretKeyFeild_bucketNameFieldFocussed() {
        let (sut, _, _, _, saverMock, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        let result = sut.textFieldShouldReturn(at: viewMock.secretKeyTextField)
        
        XCTAssertEqual(saverMock.saveCallCount, 0)
        XCTAssertEqual((viewMock.bucketNameTextField as? TextFieldMock)?.becomeFirstResponderCallCount, 1)
        XCTAssertEqual(result, false)
    }
    
    // MARK: onBack()
    
    func testOnBack_called_navigatedBack() {
        let (sut, navigatorMock, _, _, _, _, _, _, viewMock) = createSut()
        _ = viewMock
        
        sut.onBack()
        
        XCTAssertEqual(navigatorMock.goBackCallCount, 1)
    }
    
    // MARK: onLogout()
    
    func testOnLogout_called_configCleared() {
        let (sut, _, configStoreMock, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onLogout()
        
        XCTAssertEqual(configStoreMock.configSetCalls.count, 1)
        XCTAssertNil(configStoreMock.configSetCalls.last ?? nil)
    }
    
    func testOnLogout_called_fieldsAreCleared() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onLogout()
        
        XCTAssertNil(viewMock.accessKeyTextField.text)
        XCTAssertNil(viewMock.secretKeyTextField.text)
        XCTAssertNil(viewMock.bucketNameTextField.text)
    }
    
    func testOnLogout_called_barButtonsAreHidden() {
        let (sut, _, _, _, _, _, _, _, viewMock) = createSut(
            initialConfigIsSet: true
        )
        _ = viewMock
        
        sut.onLogout()
        
        XCTAssertEqual(viewMock.logoutButtonItem.isHidden, true)
        XCTAssertEqual(viewMock.backButtonItem.isHidden, true)
    }
    
    // MARK: Helper methods

    private func createSut(
        accessKeyEntered: Bool = true,
        secretKeyEntered: Bool = true,
        bucketNameEntered: Bool = true,
        initialConfigIsSet: Bool = false,
        shouldSetTags: Bool = true
    ) -> (
        SettingsControllerImpl,
        SettingsNavigatorMock,
        ApiConfigStoreMock,
        HudPresenterMock,
        SettingsSaverMock,
        AlertBuilderFactoryMock,
        AlertBuilderMock,
        AlertMock,
        SettingsViewMock
    ) {
        let navigatorMock = SettingsNavigatorMock()
        let configStoreMock = ApiConfigStoreMock()
        configStoreMock._config = initialConfigIsSet ? Copy.config : nil
        
        let hudPresenterMock = HudPresenterMock()
        let saverMock = SettingsSaverMock()
        
        let alertMock = AlertMock()
        let alertBuilderMock = AlertBuilderMock()
        alertBuilderMock.buildResult = alertMock
        let alertBuilderFactoryMock = AlertBuilderFactoryMock()
        alertBuilderFactoryMock.createAlertBuilderResult = alertBuilderMock
        
        let viewMock = SettingsViewMock()
        if !initialConfigIsSet {
            viewMock.accessKeyTextField.text = accessKeyEntered ? Copy.config.credential.accessKey : ""
            viewMock.secretKeyTextField.text = secretKeyEntered ? Copy.config.credential.secretKey : ""
            viewMock.bucketNameTextField.text = bucketNameEntered ? Copy.config.bucket.name : ""
        }
        if shouldSetTags {
            viewMock.accessKeyTextField.tag = 0
            viewMock.secretKeyTextField.tag = 1
            viewMock.bucketNameTextField.tag = 2
        }
        
        let sut = SettingsControllerImpl(
            navigator: navigatorMock,
            configStore: configStoreMock,
            hudPresenter: hudPresenterMock, 
            saver: saverMock,
            alertBuilderFactory: alertBuilderFactoryMock
        )
        sut.view = viewMock
        
        return (
            sut,
            navigatorMock,
            configStoreMock,
            hudPresenterMock,
            saverMock,
            alertBuilderFactoryMock,
            alertBuilderMock,
            alertMock,
            viewMock
        )
    }
    
    private enum Copy {
        static let config = ApiConfig.mock
        
        static let saveAlertErrorMessage = "Bucket not found"
        static let connectivityErrorMessage = "Connectivity error"
        
        static let connectivityError = NSError(domain: NSURLErrorDomain, code: 1)
    }
}
