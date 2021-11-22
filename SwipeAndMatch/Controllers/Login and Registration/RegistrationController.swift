//
//  RegistrationController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-23.
//

import UIKit
import Firebase

final class RegistrationController: UIViewController {
    //MARK: - UI Elements
    fileprivate let activity = Helper.makeActivityAlert(message: "Registering...")
    fileprivate let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .heavy)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    fileprivate let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 25
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
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
    fileprivate let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.darkGray  , for: .disabled)
        button.backgroundColor = UIColor(white: 0.80, alpha: 1)
        button.isEnabled = false
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    fileprivate let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    lazy fileprivate var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, emailTextField, passwordTextField, registerButton, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
                                  
    }()
    lazy fileprivate var mainStackView = UIStackView(arrangedSubviews: [selectPhotoButton, verticalStackView])
    fileprivate let gradientLayer = CAGradientLayer()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayerSetup()
        layoutSetup()
        observersSetup()
        gesturesSetup()
        setupRegistrationObservers()
    }
    
    override func viewWillLayoutSubviews() {
        gradientLayer.frame = view.bounds
    }
    
    //MARK: - Initialization
    let registrationViewModel = RegistrationViewModel()
    weak var delegate: LoginControllerDelegate?

    fileprivate func observersSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupRegistrationObservers() {
        registrationViewModel.bindableIsFormValid.bind { [unowned self] isFormVaild in
            guard let isFormVaild = isFormVaild else { return }
            self.registerButton.isEnabled = isFormVaild
            if isFormVaild {
                self.registerButton.backgroundColor = .clear
            } else {
                self.registerButton.backgroundColor = UIColor(white: 0.80, alpha: 1)
            }
        }
        registrationViewModel.bindableImage.bind { [unowned self] image in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        registrationViewModel.bindableIsRegistering.bind { [unowned self] isRegistring in
            if isRegistring == true {
                if self.presentedViewController == nil {
                    present(activity, animated: true)
                }
            }
        }
    }
    
    //MARK: - Layout Setup
    fileprivate func layoutSetup() {
        navigationController?.isNavigationBarHidden = true
        
        NSLayoutConstraint.activate([
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 275),
            selectPhotoButton.widthAnchor.constraint(lessThanOrEqualToConstant: 275),
//            emailTextField.heightAnchor.constraint(equalToConstant: 50),
//            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
//            nameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        [emailTextField, passwordTextField, nameTextField].forEach { textField in
            textField.setLeftPaddingPoints(value: 15)
            textField.setRightPaddingPoints(value: 15)
        }
        
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
    @objc fileprivate func handleTextChange(textField: UITextField){
        if textField == nameTextField {
            registrationViewModel.name = textField.text
        } else if textField == emailTextField {
            registrationViewModel.email = textField.text
        } else {
            registrationViewModel.password = textField.text
        }
    }
    
    @objc fileprivate func handleRegistration(){
        present(activity, animated: true)
        registrationViewModel.bindableIsRegistering.value = true
        registrationViewModel.performRegistration { [unowned self] error in
            if let error = error {
                print("Failed to register, \(error)")
                self.registrationViewModel.bindableIsRegistering.value = false
                activity.dismiss(animated: false) {
                    self.present(Helper.makeErrorAlert(title: "Registration Error", message: error.localizedDescription), animated: true)
                }
                return
            }
            activity.dismiss(animated: false) {
                self.dismiss(animated: true) {
                    delegate?.didFinishLogin()
                }
            }
            
        }

    }
    
    @objc fileprivate func handleSelectPhoto(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc fileprivate func handleGoToLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Gestures Setup
    fileprivate func gesturesSetup(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
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
}
//MARK: - ImagePicker
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkForm()
        dismiss(animated: true)
    }
}
