//
//  ViewMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

open class ViewMock: View {
    public var tag: Int = 0
    
    public var isHidden: Bool = false
    
    public var isUserInteractionEnabled: Bool = true
}
