//
//  MapViewController + Ext.swift
//  Maps
//
//  Created by Никитка on 10.07.2022.
//

import UIKit

extension MapViewController {
    
    func makeTrackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitle("Start tracking", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }
    
    func makeShowLastRouteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Show last route", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }
    
    func makeCurrentLocationButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cursor"), for: .normal)
        button.tintColor = .link
        return button
    }
}
