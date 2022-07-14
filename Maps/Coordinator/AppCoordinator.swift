//
//  AppCoordinator.swift
//  Maps
//
//  Created by Никитка on 11.07.2022.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        toAuth()
    }
    
    func toAuth(isLogout: Bool = false) {
        if isLogout {
            navigationController.popViewController(animated: true)
        }
        else {
            let authViewModel = AuthViewModel()
            authViewModel.toMap = { [weak self] in
                self?.toMap()
            }
            let authVC = AuthViewController(viewModel: authViewModel)
            navigationController.pushViewController(authVC, animated: true)
        }
    }
    
    func toMap() {
        let mapViewModel = MapViewModel()
        mapViewModel.appCoordinator = self
        let mapVC = MapViewController(viewModel: mapViewModel)
        navigationController.pushViewController(mapVC, animated: true)
    }
    
}
