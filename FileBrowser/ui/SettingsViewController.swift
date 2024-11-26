//
//  SettingsViewController.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import Foundation
import ProgressHUD

class SettingsViewController: UITableViewController {
    @IBOutlet weak var accessKey: UITextField!
    @IBOutlet weak var secretKey: UITextField!
    @IBOutlet weak var bucketName: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    private let repositoryFactory: BucketRepositoryFactory = BucketRepositoryFactoryImpl.shared
    private var configStore: ApiConfigStore = ApiConfigStoreImpl.shared
    
    private let regionLoader: BucketRegionLoader = BucketRegionLoaderImpl.shared
    private var loaderTask: Task<Void, Never>? = nil
    
    
    private var allFields: [UITextField] {
        [accessKey, secretKey, bucketName]
    }
    
    private var noFieldIsEmpty: Bool {
        allFields.allSatisfy {
            guard let text = $0.text, !text.isEmpty else {
                return false
            }
            return true
        }
    }
    
    private func save() {
        guard noFieldIsEmpty else {
            return
        }
        
        guard loaderTask == nil else {
            return
        }
        
        let credential = ApiCredentialImpl(
            accessKey: accessKey.text ?? "",
            secret: secretKey.text ?? ""
        )
        
        let bucketName = bucketName.text ?? ""
        
        loaderTask = Task {
            do {
                setSpinnerOn(true)
                let region = try await regionLoader.loadRegion(with: bucketName)
                
                let config = ApiConfigImpl(
                    credential: credential,
                    bucket: BucketImpl(
                        name: bucketName,
                        region: region
                    )
                )
                                
                configStore.config = config
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    setSpinnerOn(false)
                    
                    defer { loaderTask = nil }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController()
                                        
                    guard let window = view.window else { return }
                    
                    UIView.transition(
                        with: window,
                        duration: 0.5,
                        options: [.transitionFlipFromLeft]
                    ) {
                        window.rootViewController = vc
                    }
                }
            } catch {
                setSpinnerOn(false)
                loaderTask = nil
                print(error)
            }
        }
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapLogout(_ sender: Any) {
        configStore.config = nil
        updateFieldsValues()
        updateBarButtonsState()
    }
    
    @MainActor private func setSpinnerOn(_ isOn: Bool) {
        if isOn {
            view.isUserInteractionEnabled = false
            ProgressHUD.animationType = .circleDotSpinFade
            ProgressHUD.colorHUD = .systemGray
            ProgressHUD.colorAnimation = .tintColor
            ProgressHUD.animate()
        } else {
            ProgressHUD.dismiss()
            view.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secretKey.isSecureTextEntry = true
        
        saveButton.setTitleColor(.tintColor, for: .normal)
        saveButton.setBackgroundImage(UIImage().withTintColor(.white), for: .normal)
        
        saveButton.setTitleColor(.white, for: .highlighted)
        saveButton.setBackgroundImage(UIImage().withTintColor(.tintColor), for: .normal)
        
        updateFieldsValues()
        
        updateBarButtonsState()
        updateSaveButtonState()
    }
    
    private func updateFieldsValues() {
        let config = configStore.config
        accessKey.text = config?.credential.accessKey
        secretKey.text = config?.credential.secret
        bucketName.text = config?.bucket.name
    }
    
    private func updateBarButtonsState() {
        logoutButton.isHidden = shouldBarButtons
        backButton.isHidden = shouldBarButtons
    }
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = noFieldIsEmpty
    }
    
    private var shouldBarButtons: Bool {
        configStore.config == nil
    }
    
    func setLogoutButtonVisible(_ visible: Bool) {
        logoutButton.isHidden = !visible
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        updateSaveButtonState()
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.returnKeyType != .go 
        else  {
            save()
            return true
        }
        
        guard let index = allFields.firstIndex(of: textField),
              index + 1 < allFields.count
        else {
            return true
        }
        
        allFields[index + 1].becomeFirstResponder()
        return false
    }
}
