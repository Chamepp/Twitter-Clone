//
//  NewsTweetModel.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/24/24.
//

import UIKit

struct NewsViewModel {
    // MARK: - Properties
    let news: News
    
    var title: String {
        return news.title
    }
    
    var description: String {
        return news.description
    }
    
    var author: String {
        return news.author
    }
    
    var url: URL {
        return news.url
    }
    
    var urlToImage: URL {
        return news.urlToImage
    }
    
    var publishedAt: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: news.publishedAt, to: now) ?? "-m"
    }
    
    var content : String {
        return news.content
    }
    
    // MARK: - Lifecycle
    init(news: News) {
        self.news = news
    }
}
