//
//  SettingsController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol SettingsController: SettingsViewOutput {
    
}

final class SettingsControllerImpl: SettingsController {
    private enum SettingsField: Int {
        case accessKey = 0
        case secretKey = 1
        case bucketName = 2
        
        static let count = SettingsField.bucketName.rawValue + 1
        static let all: [SettingsField] = [accessKey, secretKey, bucketName]
    }
    
    init(
        navigator: SettingsNavigator,
        configStore: ApiConfigStore = ApiConfigStoreImpl.shared,
        hudPresenter: HudPresenter = HudPresenterImpl(),
        saver: SettingsSaver = SettingsSaverImpl(),
        alertBuilderFactory: AlertBuilderFactory = AlertBuilderFactoryImpl()
    ) {
        self.navigator = navigator
        self.configStore = configStore
        self.hudPresenter = hudPresenter
        self.saver = saver
        self.alertBuilderFactory = alertBuilderFactory
        
        self.saver.input = self
        self.saver.output = self
    }
    
    weak var view: SettingsView? = nil
    
    private let navigator: SettingsNavigator
    private var configStore: ApiConfigStore

    private let hudPresenter: HudPresenter
    private let saver: SettingsSaver
    private let alertBuilderFactory: AlertBuilderFactory
    
    private var loaderTask: Task<Void, Never>? = nil

    private var allFieldTexts: [String] {
        [accessKey(), secretKey(), bucketName()]
    }
    
    private var noFieldIsEmpty: Bool {
        allFieldTexts.allSatisfy { !$0.isEmpty }
    }
    
    private var shouldHideBarButtons: Bool {
        configStore.config == nil
    }
    
    private func setSpinnerOn(_ isOn: Bool) {
        guard let rootView = view?.rootView else { return }
        
        hudPresenter.setShown(isOn, on: rootView)
    }
    
    private func textField(_ field: SettingsField) -> TextField? {
        switch (field) {
        case .accessKey: return view?.accessKeyTextField
        case .secretKey: return view?.secretKeyTextField
        case .bucketName: return view?.bucketNameTextField
        }
    }
}

extension SettingsControllerImpl: SettingsSaverInput {
    func canSave() -> Bool {
        noFieldIsEmpty
    }
    
    func accessKey() -> String {
        view?.accessKeyTextField.text ?? ""
    }
    
    func secretKey() -> String {
        view?.secretKeyTextField.text ?? ""
    }
    
    func bucketName() -> String {
        view?.bucketNameTextField.text ?? ""
    }
}

extension SettingsControllerImpl: SettingsSaverOutput {
    func saveDidStart() {
        setSpinnerOn(true)
    }
    
    func saveDidFinish(with result: Result<Void, any Error>) {
        setSpinnerOn(false)
        
        switch result {
        case .success():
            navigator.goForward()
            
        case .failure(let error):
            guard let node = view?.node else { return }
            
            let isNetworkingError = (error as NSError).domain == NSURLErrorDomain
            
            alertBuilderFactory.createAlertBuilder()
                .setMessage(isNetworkingError ? "Connectivity error" : "Bucket not found")
                .build()
                .show(on: node, animated: true)
        }
    }
}

extension SettingsControllerImpl: SettingsViewOutput {
    func onViewLoaded() {
        view?.accessKeyTextField.tag = 0
        view?.secretKeyTextField.tag = 1
        view?.bucketNameTextField.tag = 2
        
        view?.secretKeyTextField.isSecureTextEntry = true
        
        view?.saveButton.setDefaultHighlight()
        
        updateFieldsValues()
        
        updateBarButtonsState()
        updateSaveButtonEnabled()
    }
    
    func onEditingChanged(at field: TextField) {
        updateSaveButtonEnabled()
    }
    
    func onSave() {
        saver.save()
    }
    
    func textFieldShouldReturn(at field: TextField) -> Bool {
        let index = field.tag
        
        guard index != SettingsField.count - 1 else  {
            saver.save()
            return true
        }
        
        guard index < SettingsField.count - 1,
              let field = SettingsField(rawValue: index + 1)
        else {
            return true
        }
        
        _ = textField(field)?.becomeFirstResponder()
        return false
    }
    
    func onBack() {
        navigator.goBack()
    }
    
    func onLogout() {
        configStore.config = nil
        updateFieldsValues()
        updateBarButtonsState()
    }
}

extension SettingsControllerImpl {
    private func updateFieldsValues() {
        let config = configStore.config
        
        view?.accessKeyTextField.text = config?.credential.accessKey
        view?.secretKeyTextField.text = config?.credential.secretKey
        view?.bucketNameTextField.text = config?.bucket.name
    }
    
    private func updateBarButtonsState() {
        view?.logoutButtonItem.isHidden = shouldHideBarButtons
        view?.backButtonItem.isHidden = shouldHideBarButtons
    }
    
    private func updateSaveButtonEnabled() {
        view?.saveButton.isEnabled = noFieldIsEmpty
    }
}
