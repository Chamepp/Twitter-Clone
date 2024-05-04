//
//  MainTabController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/3/24.
//

import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
    }
    
    // MARK: - Helpers
    func configureViewControllers() {
        let feed = FeedController()
        feed.tabBarItem.image = UIImage(named: "home_unselected")
        
        let explore = ExploreController()
        explore.tabBarItem.image = UIImage(named: "home_unselected")
        
        let notifictaions = NotificationsController()
        notifictaions.tabBarItem.image = UIImage(named: "home_unselected")
        
        let conversations = ConversationsController()
        conversations.tabBarItem.image = UIImage(named: "home_unselected")
        
        viewControllers = [feed, explore, notifictaions, conversations]
    }
}
