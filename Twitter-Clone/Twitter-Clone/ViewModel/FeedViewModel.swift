//
//  FeedViewModel.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/17/24.
//

import UIKit

class FeedViewModel {
    private let tweets = [Tweet]()
    
    var shouldShowEmptyLabel: Bool {
        return tweets.count == 0
    }
}
