//
//  AlertBuilderMock.swift
//  FileBrowserTests
//
//  Created by Bozhidar Mihaylov
//

import Foundation
@testable import App

final class AlertBuilderMock: AlertBuilder {
    
    private(set) var setTitleCalls: [String?] = []
    
    func setTitle(_ title: String?) -> AlertBuilder {
        setTitleCalls.append(title)
        return self
    }
    
    private(set) var setMessageCalls: [String?] = []
    
    func setMessage(_ messsage: String?) -> AlertBuilder {
        setMessageCalls.append(messsage)
        return self
    }
    
    private(set) var setCancelButtonTitleActionCalls: [(
        title: String?,
        action: AlertAction?
    )] = []
    
    func setCancelButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder {
        setCancelButtonTitleActionCalls.append((
            title: title,
            action: action
        ))
        return self
    }
    
    private(set) var setOkButtonTitleActionCalls: [(
        title: String?,
        action: AlertAction?
    )] = []
    
    func setOkButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder {
        setOkButtonTitleActionCalls.append((
            title: title,
            action: action
        ))
        return self
    }
    
    private(set) var buildCallCount = 0
    
    var buildResult: Alert! = nil
    func build() -> Alert {
        buildCallCount += 1
        
        return buildResult
    }
}
