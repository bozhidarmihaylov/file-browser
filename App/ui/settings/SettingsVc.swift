//
//  SettingsVc.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit
import Foundation
import ProgressHUD

protocol SettingsView: AnyObject {
    var rootView: View { get }
    
    var accessKeyTextField: TextField { get }
    var secretKeyTextField: TextField { get }
    var bucketNameTextField: TextField { get }
    
    var saveButton: Button { get }
    var logoutButtonItem: ButtonItem { get }
    var backButtonItem: ButtonItem { get }
    
    func setTopBarButtonsVisible(_ visible: Bool)
}

class SettingsVc: UITableViewController {
    @IBOutlet private(set) weak var _accessKeyTextField: UITextField!
    @IBOutlet private(set) weak var _secretKeyTextField: UITextField!
    @IBOutlet private(set) weak var _bucketNameTextField: UITextField!
    
    @IBOutlet private(set) weak var _saveButton: UIButton!
    @IBOutlet private(set) weak var _logoutButtonItem: UIBarButtonItem!
    @IBOutlet private(set) weak var _backButtonItem: UIBarButtonItem!
    
    var controller: SettingsController!
    
    @IBAction func didTapSave(_ sender: Any) {
        controller.onSave()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        controller.onBack()
    }
    
    @IBAction private func didTapLogout(_ sender: Any) {
        controller.onLogout()
    }
    
    private func setSpinnerOn(_ isOn: Bool) {
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
    
        controller.onViewLoaded()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        controller.onEditingChanged(at: sender.toOurTextField())
    }
}

extension SettingsVc: SettingsView {
    var rootView: View { view.toOurView() }
    
    var accessKeyTextField: TextField { _accessKeyTextField.toOurTextField() }
    var secretKeyTextField: TextField { _secretKeyTextField.toOurTextField() }
    var bucketNameTextField: TextField { _bucketNameTextField.toOurTextField() }
    
    var saveButton: Button { _saveButton.toOurButton() }
    
    var logoutButtonItem: ButtonItem { _logoutButtonItem.toOurButtonItem() }
    var backButtonItem: ButtonItem { _backButtonItem.toOurButtonItem() }
    
    func setTopBarButtonsVisible(_ visible: Bool) {
        _logoutButtonItem.isHidden = !visible
        _backButtonItem.isHidden = !visible
    }
}

extension SettingsVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        controller.textFieldShouldReturn(at: textField.toOurTextField())
    }
}
