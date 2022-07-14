//
//  UIViewController + Ext.swift
//  Maps
//
//  Created by Никитка on 08.07.2022.
//

import UIKit

extension UIViewController {
    func showError(title: String? = "Error", message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let closeAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
}
