//
//  AuthService.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/12/24.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let username = credentials.username
        let fullname = credentials.fullname
        
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        guard let topController = UIApplication.shared.topViewController() else {
            print("DEBUG: No top view controller found")
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metta, error in
            storageRef.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        AlertManager.shared.presentCredentialsAlert(onController: topController, title: "Error", message: error.localizedDescription)
                        print("DEBUG: Couldn't Register The User: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let data = [
                        "email": email,
                        "username": username,
                        "fullname": fullname,
                        "profileImageUrl": profileImageUrl
                    ]
                    
                    let allValuesAvailable = data.values.allSatisfy { !$0.isEmpty }
                    
                    if allValuesAvailable {
                        REF_USERS.child(uid).updateChildValues(data, withCompletionBlock: completion)
                    } else {
                        AlertManager.shared.presentCredentialsAlert(onController: topController, title: "Missing Credentials", message: "Please fill all the required data")
                        return
                    }
                }
            }
        }
    }
}
