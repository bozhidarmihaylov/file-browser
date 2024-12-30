//
//  HudPresenterMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class HudPresenterMock: HudPresenter {
    private(set) var setShownOnViewCalls: [(
        shown: Bool,
        view: View
    )] = []
    func setShown(_ shown: Bool, on view: View) {
        setShownOnViewCalls.append((
            shown: shown,
            view: view
        ))
    }
}
