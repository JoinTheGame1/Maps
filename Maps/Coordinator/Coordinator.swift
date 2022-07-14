//
//  Coordinator.swift
//  Maps
//
//  Created by Никитка on 11.07.2022.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    
    func start()
}
