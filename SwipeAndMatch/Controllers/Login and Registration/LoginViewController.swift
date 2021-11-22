//
//  LoginViewController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-30.
//

import UIKit

protocol LoginControllerDelegate: AnyObject {
    func didFinishLogin()
}

final class LoginViewController: UIViewController {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayerSetup()
        layoutSetup()
        gesturesSetup()
        observersSetup()
    }
    
    override func viewWillLayoutSubviews() {
        gradientLayer.frame = view.bounds
    }
    
    //MARK: - Initialization
    weak var delegate: LoginControllerDelegate?
    fileprivate let loginViewModel = LoginViewModel()
    
    fileprivate func observersSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupLoginObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupLoginObservers() {
        loginViewModel.isFormValid.bind { [unowned self] isFormVaild in
            guard let isFormVaild = isFormVaild else { return }
            self.loginButton.isEnabled = isFormVaild
            if isFormVaild {
                self.loginButton.backgroundColor = UIColor.clear
            } else {
                self.loginButton.backgroundColor = UIColor(white: 0.80, alpha: 1)
            }
        }
        loginViewModel.isLogginIn.bind { [unowned self] isLogignIn in
            if isLogignIn == true {
                if self.presentedViewController == nil {
                    present(activity, animated: true)
                }
            }
        }
    }
    
    //MARK: - UI Elements
    fileprivate let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter email"
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 25
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    fileprivate let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 25
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    fileprivate let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.darkGray  , for: .disabled)
        button.backgroundColor = UIColor(white: 0.80, alpha: 1)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.isEnabled = false
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    fileprivate let goBackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New user? Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(handleGoToRegistration), for: .touchUpInside)
        return button
    }()
    lazy fileprivate var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, goBackButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        
    }()
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let activity = Helper.makeActivityAlert(message: "Logging in...")
    
    //MARK: - Layout Setup
    fileprivate func layoutSetup() {
        emailTextField.setLeftPaddingPoints(value: 15)
        emailTextField.setRightPaddingPoints(value: 15)
        passwordTextField.setLeftPaddingPoints(value: 15)
        passwordTextField.setRightPaddingPoints(value: 15)
        
        NSLayoutConstraint.activate([
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        navigationController?.isNavigationBarHidden = true
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        view.addSubview(mainStackView)
        mainStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            mainStackView.axis = .horizontal
        } else {
            mainStackView.axis = .vertical
        }
    }
    
    fileprivate func gradientLayerSetup(){
        let topColor = Colors.gradientStart
        let buttomColor = Colors.gradientEnd
        gradientLayer.colors = [topColor.cgColor, buttomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleKeyboardShow(notification: Notification){
        guard let keyBoardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyBoardFrameValue.cgRectValue
        let buttomSpace = view.frame.height - mainStackView.frame.origin.y - mainStackView.frame.height
        let difference = keyboardFrame.height - buttomSpace
        UIView.animate(withDuration: 0.2) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 10)
        }
    }
    
    @objc fileprivate func handleKeyboardHide(notification: Notification){
        UIView.animate(withDuration: 0.2) {
            self.view.transform = .identity
        }
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField){
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    
    @objc fileprivate func handleLogin(){
        loginViewModel.isLogginIn.value = true
        loginViewModel.performLogin { [unowned self] error in
            if let error = error {
                self.loginViewModel.isLogginIn.value = false
                print("Failed to login, \(error)")
                activity.dismiss(animated: false) {
                    self.present(Helper.makeErrorAlert(title: "Login Error", message: error.localizedDescription), animated: true)
                }
                return
            }
            activity.dismiss(animated: false) {
                self.dismiss(animated: true) {
                    self.delegate?.didFinishLogin()
                }
            }
        }
        
    }
    
    @objc fileprivate func handleGoToRegistration() {
        let registrationViewController = RegistrationController()
        registrationViewController.delegate = delegate
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
    
    //MARK: - Gestures Setup
    fileprivate func gesturesSetup(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
