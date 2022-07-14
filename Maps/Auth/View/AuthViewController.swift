//
//  AuthViewController.swift
//  Maps
//
//  Created by Никитка on 11.07.2022.
//

import UIKit
import SnapKit

class AuthViewController: UIViewController {
    
    var viewModel: AuthViewModel
    lazy var loginTextField: UITextField = makeLoginTextField()
    lazy var passwordTextField: UITextField = makePasswordTextField()
    lazy var signInButton: UIButton = makeSignInButton()
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWasShown(notification: Notification) {
        addTapOnView()
    }
    
    @objc private func keyboardWillBeHidden(notification: Notification) {
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    private func addTapOnView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc func signIn() {
        if loginTextField.text == "123" && passwordTextField.text == "123" {
            viewModel.toMap?()
        } else {
            loginTextField.text = ""
            passwordTextField.text = ""
            loginTextField.shake(translationX: 20, y: 0)
            passwordTextField.shake(translationX: 20, y: 0)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        loginTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        passwordTextField.snp.makeConstraints { make in
            make.leading.equalTo(loginTextField.snp.leading)
            make.trailing.equalTo(loginTextField.snp.trailing)
            make.top.equalTo(loginTextField.snp.bottom).inset(-8)
            make.height.equalTo(loginTextField.snp.height)
        }
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).inset(-8)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
}
