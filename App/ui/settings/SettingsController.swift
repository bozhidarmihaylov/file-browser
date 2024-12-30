//
//  SettingsController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol SettingsController {
    func textFieldShouldReturn(at field: TextField) -> Bool
    
    func onViewLoaded()
    
    func onEditingChanged(at field: TextField)
    
    func onSave()
    func onBack()
    func onLogout()
}

final class SettingsControllerImpl {
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
        regionLoader: BucketRegionLoader = BucketRegionLoaderImpl.shared,
        hudPresenter: HudPresenter = HudPresenterImpl(),
        mainActorRunner: MainActorRunner = MainActorRunnerImpl()
    ) {
        self.navigator = navigator
        self.configStore = configStore
        self.regionLoader = regionLoader
        self.hudPresenter = hudPresenter
        self.mainActorRunner = mainActorRunner
    }
    
    weak var view: SettingsView? = nil
    
    private let navigator: SettingsNavigator
    private var configStore: ApiConfigStore
    
    private let regionLoader: BucketRegionLoader
    
    private let hudPresenter: HudPresenter
    private let mainActorRunner: MainActorRunner
    
    private var loaderTask: Task<Void, Never>? = nil

    private var accessKey: String { view?.accessKeyTextField.text ?? "" }
    private var secretKey: String { view?.secretKeyTextField.text ?? "" }
    private var bucketName: String { view?.bucketNameTextField.text ?? "" }

    private var allFieldTexts: [String] {
        [accessKey, secretKey, bucketName]
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

extension SettingsControllerImpl: SettingsController {
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
    
    func onSave() {
        save()
    }
    
    func textFieldShouldReturn(at field: TextField) -> Bool {
        let index = field.tag
        
        guard index != SettingsField.count - 1 else  {
            save()
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
    private func save() {
        guard noFieldIsEmpty else {
            return
        }
        
        guard loaderTask == nil else {
            return
        }
        
        let credential = ApiCredential(
            accessKey: accessKey,
            secretKey: secretKey
        )
        
        let bucketName = bucketName
        
        setSpinnerOn(true)
        
        loaderTask = Task {
            do {
                let region = try await regionLoader.loadRegion(with: bucketName)
                
                let config = ApiConfig(
                    credential: credential,
                    bucket: Bucket(
                        name: bucketName,
                        region: region
                    )
                )
                                
                configStore.config = config
                
                await mainActorRunner.run { [weak self] in
                    guard let self else { return }
                    
                    setSpinnerOn(false)
                    
                    defer { loaderTask = nil }

                    navigator.goForward()
                }
            } catch {
                await mainActorRunner.run {
                    setSpinnerOn(false)
                }
                loaderTask = nil
                print(error)
            }
        }
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
    
    func onEditingChanged(at field: TextField) {
        updateSaveButtonEnabled()
    }
}
