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
    var node: Node! { get }
    
    var rootView: View! { get }
    
    var accessKeyTextField: TextField! { get }
    var secretKeyTextField: TextField! { get }
    var bucketNameTextField: TextField! { get }
    
    var saveButton: Button! { get }
    var logoutButtonItem: ButtonItem! { get }
    var backButtonItem: ButtonItem! { get }
    
    func setTopBarButtonsVisible(_ visible: Bool)
    
    var output: SettingsViewOutput? { get set }
}

protocol SettingsViewOutput {
    func textFieldShouldReturn(at field: TextField) -> Bool
    
    func onViewLoaded()
    
    func onEditingChanged(at field: TextField)
    
    func onSave()
    func onBack()
    func onLogout()
}

class SettingsVc: UITableViewController {
    @IBOutlet private(set) weak var _accessKeyTextField: UITextField!
    @IBOutlet private(set) weak var _secretKeyTextField: UITextField!
    @IBOutlet private(set) weak var _bucketNameTextField: UITextField!
    
    @IBOutlet private(set) weak var _saveButton: UIButton!
    @IBOutlet private(set) weak var _logoutButtonItem: UIBarButtonItem!
    @IBOutlet private(set) weak var _backButtonItem: UIBarButtonItem!
    
    var output: SettingsViewOutput?
    
    @IBAction func didTapSave(_ sender: Any) {
        output?.onSave()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        output?.onBack()
    }
    
    @IBAction private func didTapLogout(_ sender: Any) {
        output?.onLogout()
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
    
        output?.onViewLoaded()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        output?.onEditingChanged(at: sender.toOurTextField())
    }
}

extension SettingsVc: SettingsView {
    var node: Node! { NodeImpl(vc: self) }
    
    var rootView: View! { view.toOurView() }
    
    var accessKeyTextField: TextField! { _accessKeyTextField.toOurTextField() }
    var secretKeyTextField: TextField! { _secretKeyTextField.toOurTextField() }
    var bucketNameTextField: TextField! { _bucketNameTextField.toOurTextField() }
    
    var saveButton: Button! { _saveButton.toOurButton() }
    
    var logoutButtonItem: ButtonItem! { _logoutButtonItem.toOurButtonItem() }
    var backButtonItem: ButtonItem! { _backButtonItem.toOurButtonItem() }
    
    func setTopBarButtonsVisible(_ visible: Bool) {
        _logoutButtonItem.isHidden = !visible
        _backButtonItem.isHidden = !visible
    }
}

extension SettingsVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        output?.textFieldShouldReturn(at: textField.toOurTextField()) ?? false
    }
}
