//
//  AuthViewModel.swift
//  Maps
//
//  Created by Никитка on 11.07.2022.
//

import Foundation

class AuthViewModel {
    
    weak var appCoordinator: AppCoordinator?
    
    var toMap: (() -> Void)?
}
