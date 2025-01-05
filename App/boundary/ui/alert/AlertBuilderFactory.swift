//
//  AlertBuilderFactory.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol AlertBuilderFactory {
    func createAlertBuilder() -> AlertBuilder
}

struct AlertBuilderFactoryImpl: AlertBuilderFactory {
    func createAlertBuilder() -> AlertBuilder { AlertBuilderImpl() }
}
