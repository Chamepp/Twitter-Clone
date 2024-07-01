//
//  ActivityController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 6/28/24.
//

import UIKit

class ActivityController: UIActivityViewController {
    static func presentActivity(onController controller: UIViewController, for tweetID: String) {
        let url = URL(string: "TwitterClone://tweet/id/\(tweetID)")
        
        let items: [Any] = [url]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: .none)
        
        controller.present(activityController, animated: true)
    }
}