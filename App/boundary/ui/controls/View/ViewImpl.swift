//
//  ViewImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

open class ViewImpl: View {
    init(uiView: UIView) {
        _uiView = uiView
    }
    
    private let _uiView: UIView
    
    var tag: Int {
        get { _uiView.tag }
        set { _uiView.tag = newValue }
    }
    
    var isHidden: Bool {
        get { _uiView.isHidden }
        set { _uiView.isHidden = newValue }
    }
    
    var isUserInteractionEnabled: Bool {
        get { _uiView.isUserInteractionEnabled }
        set { _uiView.isUserInteractionEnabled = newValue }
    }
}

extension UIView {
    func toOurView() -> View {
        ViewImpl(uiView: self)
    }
}
