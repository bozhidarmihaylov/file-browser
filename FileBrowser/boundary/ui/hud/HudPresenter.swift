//
//  HudPresenter.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation

// sourcery: AutoMockable
protocol HudPresenter {
    func setShown(_ shown: Bool,  on view: View)
}
