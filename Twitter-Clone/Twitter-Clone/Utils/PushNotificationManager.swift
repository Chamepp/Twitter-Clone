//
//  NotificationManager.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/6/24.
//

import UIKit

class PushNotificationManager {
    static let shared = PushNotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    enum notificationIdentifier: String {
        case appActivity
        case tweetActivity
    }
    
    func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
                return
            }
        }
    }
    
    func scheduleNotification(title: String? = "Twitter", identifier: notificationIdentifier) {
        var date = DateComponents()
        
        let content = UNMutableNotificationContent()
        content.title = title ?? "N/A"
        content.sound = UNNotificationSound.default
        
        switch identifier {
            case .appActivity:
                content.body = "It's been a while since your last activity. See what's happening."
                date.day = 1
            case .tweetActivity:
                content.body = "It's been 3 days since your last tweet. Don't forget to send your tweets for the week."
                date.day = 3
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
}
