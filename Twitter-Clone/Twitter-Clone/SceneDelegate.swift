//
//  SceneDelegate.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/3/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var currentNavigation: String?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = MainTabController()
        window?.makeKeyAndVisible()
        
        // Determine who sent the URL.
        guard let urlContext = connectionOptions.urlContexts.first else { return }
        let url = urlContext.url
        
        handleURL(url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url
        
        handleURL(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func handleURL(_ url: URL) {
        let type = url.host
        let id = url.pathComponents[2]
        
        switch type {
            case "tweet":
                currentNavigation = "tweet"
                TweetService.shared.fetchTweet(withTweetID: id) { tweet in
                    // Assuming you have a UITabBarController set as your window's rootViewController
                    guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }

                    // Assuming the feed controller (listViewController) is the first tab (index 0)
                    if let feedNavigationController = tabBarController.viewControllers?.first as? UINavigationController {
                        
                        // Passing the tweet object to the Tweet Controller
                        let tweetController = TweetController(tweet: tweet)
                        
                        // Push TweetController onto the navigation stack of the feed controller's navigation controller
                        feedNavigationController.pushViewController(tweetController, animated: true)
                        
                        // Optionally, you may want to ensure the feed controller is selected in the tab bar
                        tabBarController.selectedIndex = 0
                    } else {
                        print("ERROR: Unable to get feedNavigationController as UINavigationController from tabBarController")
                    }
                }
            default:
                break
        }
    }
}

