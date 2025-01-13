//
//  ErrorAlertPresenter.swift
//  App
//
//  Created by Bozhidar Mihaylov
//

import Foundation

protocol ErrorAlertPresenter {
    func showErrorAlert(
        of error: Error,
        with message: String,
        on node: Node?
    )
}

struct ErrorAlertPresenterImpl: ErrorAlertPresenter {
    init(
        alertBuilderFactory: AlertBuilderFactory = AlertBuilderFactoryImpl()
    ) {
        self.alertBuilderFactory = alertBuilderFactory
    }
    
    private let alertBuilderFactory: AlertBuilderFactory
    
    func showErrorAlert(
        of error: Error,
        with message: String,
        on node: Node?
    ) {
        guard let node else {
            return
        }
        
        let isNetworkingError = (error as NSError).domain == NSURLErrorDomain
        
        let msg = isNetworkingError ? "Connectivity error" : message
        
        alertBuilderFactory.createAlertBuilder()
            .setMessage(msg)
            .build()
            .show(on: node, animated: true)
        
        NSLog("\(msg): \(error)")
    }
}
