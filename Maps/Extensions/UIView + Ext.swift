//
//  UIView + Ext.swift
//  Maps
//
//  Created by Никитка on 15.07.2022.
//

import UIKit

extension UIView {
    func shake(translationX dx: CGFloat, y dy: CGFloat) {
        self.transform = CGAffineTransform(translationX: dx, y: dy)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
