//
//  LoginController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/7/24.
//

import UIKit

class LoginController: UIViewController {
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "twitter_logo_black")
        return iv
    }()
    
    private let logInLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In To Twitter"
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.textColor = .black
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "mail")?.withRenderingMode(.alwaysOriginal), textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "password"), textField: passwordTextField)
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
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Sign up for Twitter")
        button.addTarget(self, action: #selector(handleShowSignup), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = Utilities().attributedButton("Forgot Password ?")
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    
    private let seperatorCircle: UILabel = {
        let label = UILabel()
        label.text = "·"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleLogin() {
        guard let email = emailTextField.text?.lowercased() else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                AlertManager.shared.presentCredentialsAlert(onController: self, title: "Invalid Credentials", message: "The email or password you entered is incorrect. Please try again.")
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            
            guard let tab = window.rootViewController as? MainTabController else { return }
            
            tab.authenticateUserAndConfigureUI()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleShowSignup() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleForgotPassword() {
        let controller = ForgotPasswordController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 100)
        logoImageView.setDimensions(width: 100, height: 100)
        
        let fieldStack = UIStackView(arrangedSubviews: [logInLabel, emailContainerView, passwordContainerView, loginButton])
        fieldStack.axis = .vertical
        fieldStack.spacing = 20
        fieldStack.distribution = .fillEqually
        
        view.addSubview(fieldStack)
        fieldStack.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        fieldStack.centerY(inView: view)
        
        let labelStack = UIStackView(arrangedSubviews: [forgotPasswordButton, seperatorCircle, dontHaveAccountButton])
        labelStack.axis = .horizontal
        labelStack.distribution = .equalSpacing
        
        view.addSubview(labelStack)
        labelStack.anchor(top: fieldStack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 60, paddingRight: 60)
        labelStack.centerX(inView: view)
    }
}
