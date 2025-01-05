//
//  AlertImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import UIKit

final class AlertBuilderImpl: AlertBuilder {
    private var title: String? = nil
    func setTitle(_ title: String?) -> AlertBuilder {
        self.title = title
        return self
    }
    
    private var message: String? = nil
    func setMessage(_ message: String?) -> AlertBuilder {
        self.message = message
        return self
    }
    
    private var cancelButtonTitle: String? = nil
    private var cancelButtonAction: AlertAction? = nil
    func setCancelButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder {
        cancelButtonTitle = title
        cancelButtonAction = action
        return self
    }
    
    private var okButtonTitle: String? = nil
    private var okButtonAction: AlertAction? = nil
    func setOkButtonTitle(_ title: String?, action: AlertAction?) -> AlertBuilder {
        okButtonTitle = title
        okButtonAction = action
        return self
    }
    
    private func uiAlertAction(
        from alertAction: AlertAction?,
        in alert: Alert
    ) -> ((UIAlertAction) -> Void)?  {
        alertAction.map { action in
            { _ in
                action(alert)
            }
        }
    }
    
    func build() -> Alert {
        let alertVc = UIAlertController()
        alertVc.title = title
        alertVc.message = message
        
        let node = NodeImpl(vc: alertVc)
        
        let alert = AlertImpl(node: node)
        
        if let cancelButtonTitle {
            alertVc.addAction(
                UIAlertAction(
                    title: cancelButtonTitle,
                    style: .cancel,
                    handler: cancelButtonAction.map { action in
                        { _ in
                            action(alert)
                        }
                    }
                )
            )
        }
        
        if let okButtonTitle {
            alertVc.addAction(
                UIAlertAction(
                    title: okButtonTitle,
                    style: .default,
                    handler: okButtonAction.map { action in
                        { _ in
                            action(alert)
                        }
                    }
                )
            )
        }
        
        return alert
    }
    
    struct ButtonImpl {
        let title: String
        let action: ((Alert) -> Void)?
    }
}

struct AlertImpl: Alert {
    init(
        node: Node
    ) {
        self.node = node
    }
    
    private let node: Node
    
    func show(on node: Node, animated: Bool) {
        node.present(node, animated: animated)
    }
    
    func hide(animated: Bool) {
        node.dismiss(animated: animated)
    }
}
