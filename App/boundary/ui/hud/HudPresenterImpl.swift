//
//  HudPresenterImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import ProgressHUD

struct HudPresenterImpl: HudPresenter {
    func setShown(_ shown: Bool,  on view: View) {
        if (shown) {
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
}
