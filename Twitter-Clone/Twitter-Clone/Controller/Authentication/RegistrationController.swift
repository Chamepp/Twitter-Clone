//
//  RegistrationController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/7/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegistrationController: UIViewController {
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    private let imagePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "mail")?.withRenderingMode(.alwaysOriginal), textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "password"), textField: passwordTextField)
        return view
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "name"), textField: fullnameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "user"), textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email", isSecure: false, isWhiteSpaceAllowed: false, textColor: UIColor.black)
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password", isSecure: true, textColor: UIColor.black)
        return tf
    }()
    
    private let fullnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Full Name", isSecure: false, textColor: UIColor.black)
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Username", isSecure: false, isWhiteSpaceAllowed: false, textColor: UIColor.black)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let registrationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account ? Login")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleRegistration() {
        guard let profileImage = profileImage else {
            AlertManager.shared.presentCredentialsAlert(onController: self, title: "Missing Credentials", message: "Please select a profile image.")
            print("DEBUG: Please select a profile image.")
            return
        }
        guard let email = emailTextField.text?.lowercased() else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text?.lowercased() else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.shared.registerUser(credentials: credentials) { error, ref in
            if let error = error {
                AlertManager.shared.presentCredentialsAlert(onController: self, title: "Error", message: "\(error.localizedDescription)")
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            
            guard let tab = window.rootViewController as? MainTabController else { return }
            
            tab.authenticateUserAndConfigureUI()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleAddProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(imagePickerButton)
        imagePickerButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        imagePickerButton.setDimensions(width: 100, height: 100)
        
        let stack = UIStackView(arrangedSubviews: [
            emailContainerView, passwordContainerView, fullnameContainerView, usernameContainerView, registrationButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: imagePickerButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10)
        alreadyHaveAccountButton.centerX(inView: view)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        imagePickerButton.layer.cornerRadius = 20
        imagePickerButton.layer.masksToBounds = true
        imagePickerButton.imageView?.contentMode = .scaleAspectFit
        imagePickerButton.imageView?.clipsToBounds = true
        imagePickerButton.layer.borderColor = UIColor.black.cgColor
        imagePickerButton.layer.borderWidth = 3
        
        self.imagePickerButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}
