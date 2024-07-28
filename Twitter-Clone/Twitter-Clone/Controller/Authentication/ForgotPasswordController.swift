//
//  ForgotPasswordController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/27/24.
//

import Firebase
import UIKit

class ForgotPasswordController: UIViewController {
    // MARK: Properties
    private let resetPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset Password"
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.textColor = .black
        return label
    }()
    
    private let resetPasswordDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please add the email address associated with your account and we will send a password reset link"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(withImage: UIImage(named: "mail")?.withRenderingMode(.alwaysOriginal), textField: emailTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email", isSecure: false, isWhiteSpaceAllowed: false, textColor: UIColor.black)
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account ? Login")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    // MARK: API
    
    // MARK: Selectors
    @objc func handleResetPassword() {
        guard let email = emailTextField.text?.lowercased() else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("DEBUG: Unable to reset password: \(error.localizedDescription)")
            }
            
            print("DEBUG: Reset password link sent to the provided email")
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        
        let labelStack = UIStackView(arrangedSubviews: [resetPasswordLabel, resetPasswordDescriptionLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 15
        labelStack.distribution = .fillEqually
        
        let fieldStack = UIStackView(arrangedSubviews: [emailContainerView, resetPasswordButton])
        fieldStack.axis = .vertical
        fieldStack.spacing = 15
        fieldStack.distribution = .fillEqually
        
        
        view.addSubview(labelStack)
        labelStack.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 340, paddingLeft: 32, paddingRight: 32)
        
        
        view.addSubview(fieldStack)
        fieldStack.anchor(top: labelStack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: fieldStack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10)
    }
}
