//
//  MainTabController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/3/24.
//

import UIKit
import Firebase

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            
            feed.user = user
        }
    }
    
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        let currentUid = Auth.auth().currentUser
        
        if currentUid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureUI()
            configureViewControllers()
            fetchUser()
        }
    }
    
    // MARK: - Selectors
    @objc func actionButtonTapped() {
        guard let user = user else { return }
        let controller = UploadTweetController(user: user, config: .tweet)
        let nav = Utilities().templateNavigationController(image: nil, rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        print("DEBUG: Presented the view")
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingBottom: 64,
            paddingRight: 16,
            width: 56,
            height: 56
        )
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    
    func configureViewControllers() {
        let feed = Utilities().templateNavigationController(image: UIImage(named: "home"), rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let explore = Utilities().templateNavigationController(image: UIImage(named: "search"), rootViewController: ExploreController())

        let notifications = Utilities().templateNavigationController(image: UIImage(named: "notification"), rootViewController: NotificationsController())

        let conversations = Utilities().templateNavigationController(image: UIImage(named: "news"), rootViewController: NewsController())
        
        viewControllers = [feed, explore, notifications, conversations]
    }
    
    func handleCustomURL(_ url: URL) {
            let host = url.host
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        // Perform actions based on the URL
            print("Handled in ViewController - Host: \(host ?? "")")
            print("Handled in ViewController - Query Items: \(String(describing: queryItems))")
            
            // For example, you can update the label with URL information
            if let label = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = "URL: \(url.absoluteString)"
            }
        }
}
