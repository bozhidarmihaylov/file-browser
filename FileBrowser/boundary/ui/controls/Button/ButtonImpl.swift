//
//  ButtonImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class ButtonImpl: ViewImpl, Button {
    init(uiButton: UIButton) {
        _uiButton = uiButton
        
        super.init(uiView: uiButton)
    }
    
    private let _uiButton: UIButton
    
    var isEnabled: Bool {
        get { _uiButton.isEnabled }
        set { _uiButton.isEnabled = newValue }
    }
    
    func setDefaultHighlight() {
        _uiButton.setTitleColor(.white, for: .normal)
        _uiButton.setBackgroundImage(UIImage().withTintColor(.tintColor), for: .normal)
        
        _uiButton.setTitleColor(.tintColor, for: .highlighted)
        _uiButton.setBackgroundImage(UIImage().withTintColor(.white), for: .highlighted)
    }
}

extension UIButton {
    func toOurButton() -> Button {
        ButtonImpl(uiButton: self)
    }
}
