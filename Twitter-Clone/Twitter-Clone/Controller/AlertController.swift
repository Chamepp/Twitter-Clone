//
//  AlertController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 6/21/24.
//

import Firebase
import UIKit

class AlertController: UIAlertController {
    static func presentLogoutAlert(onController controller: UIViewController, title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertLogoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            completion()
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(alertLogoutAction)
        alert.addAction(alertCancelAction)
        
        controller.present(alert, animated: true, completion: nil)
    }
}
