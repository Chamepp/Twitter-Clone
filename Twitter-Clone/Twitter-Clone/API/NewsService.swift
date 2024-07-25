//
//  NewsService.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 7/24/24.
//

import Firebase

struct NewsService {
    static let shared = NewsService()
    
    func fetchNews(completion: @escaping ([News]) -> Void) {
        let apiKey = "875eb98b2eca49cfa90c90a7cf73431d"
        let urlString = "https://newsapi.org/v2/top-headlines?sources=fox-news&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("DEBUG: Unable to fetch news \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                let news = newsResponse.articles.map { article in
                    let values = [
                        "title": article.title,
                        "description": article.description as Any,
                        "author": article.author as Any,
                        "url": article.url,
                        "urlToImage": article.urlToImage as Any,
                        "publishedAt": article.publishedAt,
                        "content": article.content as Any
                    ] as [String: AnyObject]
                    
                    let data = News(id: UUID().uuidString, dictionary: values)
                    
                    return data
                }
                DispatchQueue.main.async {
                    completion(news)
                }
            } catch {
                return
            }
        }.resume()
    }
}
