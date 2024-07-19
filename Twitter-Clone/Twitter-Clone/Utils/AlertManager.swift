//
//  AlertController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 6/21/24.
//

import Firebase
import UIKit

class AlertManager {
    static let shared = AlertManager()
    
    func presentLogoutAlert(onController controller: UIViewController, title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertLogoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            completion()
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(alertLogoutAction)
        alert.addAction(alertCancelAction)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    func presentCredentialsAlert(onController controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertOkAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(alertOkAction)
        
        controller.present(alert, animated: true, completion: nil)
    }
}
