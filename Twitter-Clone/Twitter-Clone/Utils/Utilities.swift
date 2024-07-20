//
//  Utilities.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/8/24.
//

import UIKit

class Utilities {
    func inputContainerView(withImage image: UIImage?, textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        iv.image = image
        
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, paddingLeft: 8)
        iv.centerY(inView: view)
        iv.setDimensions(width: 24, height: 24)
        
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8)
        textField.centerY(inView: view)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        
        view.addSubview(dividerView)
        dividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        
        
        return view
    }
    
    func textField(withPlaceholder placeholder: String, isSecure: Bool, isWhiteSpaceAllowed: Bool = true, textColor: UIColor) -> UITextField {
        let tf = UITextField()
        tf.textColor = textColor
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        if !isWhiteSpaceAllowed {
            tf.delegate = TextFieldDelegate.shared
        }
        
        if isSecure {
            tf.isSecureTextEntry = true
        }
        
        return tf
    }
    
    func attributedButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        nav.tabBarItem.image = image
        
        return nav
    }
}

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    static let shared = TextFieldDelegate()

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the replacement string contains any whitespace
        if string.rangeOfCharacter(from: .whitespaces) != nil {
            return false // Return false to prevent the change
        }
        return true // Allow the change
    }
}
