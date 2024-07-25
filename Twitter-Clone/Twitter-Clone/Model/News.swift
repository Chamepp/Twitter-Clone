//
//  News.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/24/24.
//

import Foundation

struct News: Codable {
//    let id: String
    let title: String
    let description: String
    let author: String
    let url: URL
    let urlToImage: URL
    let publishedAt: Date
    let content: String
    
    init(id: String, dictionary: [String: AnyObject]) {
//        self.id = id
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.content = dictionary["content"] as? String ?? ""
        
        if let urlString = dictionary["url"] as? String, let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = URL(string: "https://default.url")!  // Default URL
        }
        
        if let urlToImageString = dictionary["urlToImage"] as? String, let urlToImage = URL(string: urlToImageString) {
            self.urlToImage = urlToImage
        } else {
            self.urlToImage = URL(string: "https://default.url/to/image")!  // Default URL
        }
        
        if let publishedAtTimestamp = dictionary["publishedAt"] as? Double {
            self.publishedAt = Date(timeIntervalSince1970: publishedAtTimestamp)
        } else {
            self.publishedAt = Date()  // Default to current date
        }
    }
}

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}

