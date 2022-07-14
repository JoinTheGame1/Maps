//
//  BottomView.swift
//  BottomViewTest
//
//  Created by Никитка on 12.07.2022.
//

import Foundation
import UIKit
import SnapKit

class BottomView: UIView {
    
    var viewModel: MapViewModel? {
        didSet {
            setupViewModel()
        }
    }
    let cornerRadius: CGFloat = 16
    let viewColor: UIColor = .systemGray5
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 100)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.backward",
                                withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let trackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 100)
        button.setImage(UIImage(systemName: "play.circle",
                                withConfiguration: configuration), for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    let centerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let showLastRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 100)
        button.setImage(UIImage(systemName: "location",
                                withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    @objc private func trackButtonAction() {
        self.viewModel?.trackButtonTapped()
    }
    
    @objc private func showLastRouteButtonAction() {
        self.viewModel?.showLastRouteButtonTapped()
    }
    
    func setupUI() {
        self.backgroundColor = viewColor
        self.centerView.backgroundColor = viewColor
        self.layer.cornerRadius = self.cornerRadius
        self.addSubview(centerView)
        centerView.addSubview(trackButton)
        self.addSubview(logoutButton)
        self.addSubview(showLastRouteButton)
        
        trackButton.addTarget(self, action: #selector(trackButtonAction), for: .touchUpInside)
        showLastRouteButton.addTarget(self, action: #selector(showLastRouteButtonAction), for: .touchUpInside)
        
        let smallButtonHeight = self.frame.height / 3
        let centerViewHeight = self.frame.height
        self.centerView.layer.cornerRadius = centerViewHeight / 2
        centerView.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.top).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(centerViewHeight)
            make.height.equalTo(centerViewHeight)
        }
        trackButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().inset(8)
            make.height.equalToSuperview().inset(8)
        }
        logoutButton.snp.makeConstraints { make in
            make.centerY.equalTo((self.frame.height - self.cornerRadius) / 2)
            make.centerX.equalTo(self.frame.width / 6)
            make.height.equalTo(smallButtonHeight)
            make.width.equalTo(smallButtonHeight)
        }
        showLastRouteButton.snp.makeConstraints { make in
            make.centerY.equalTo((self.frame.height - self.cornerRadius) / 2)
            make.centerX.equalTo(self.frame.width / 6 * 5)
            make.height.equalTo(smallButtonHeight)
            make.width.equalTo(smallButtonHeight)
        }
    }
    
    private func setupViewModel() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 100)
        viewModel?.trackButtonAnimate = { [weak self] model in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.trackButton.setImage(UIImage(systemName: model.isTracking ? "stop.circle" : "play.circle",
                                                  withConfiguration: configuration), for: .normal)
                self.trackButton.tintColor = model.isTracking ? .systemRed : .systemGreen
            }
        }
    }
}
