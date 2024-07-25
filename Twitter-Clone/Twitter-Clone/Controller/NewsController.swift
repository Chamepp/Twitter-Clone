//
//  NewsController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/4/24.
//


import UIKit

private let reuseIdentifier = "NewsCell"

class NewsController: UITableViewController {
    // MARK: - Properties
    private var news = [News]() {
        didSet {
            tableView.reloadData()
            activityIndicator.stopAnimating()
        }
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: API
    func fetchNews() {
        activityIndicator.startAnimating()
        NewsService.shared.fetchNews { news in
            self.news = news
        }
    }
    
    // MARK: Selectors
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "News"
        
        view.addSubview(activityIndicator)
        activityIndicator.anchor(top: view.topAnchor, bottom: view.bottomAnchor, paddingTop: 360)
        activityIndicator.centerX(inView: tableView)
        
        tableView.register(NewsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 400
        tableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDataSource
extension NewsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewsCell
        let news = news[indexPath.row]
        cell.news = news
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = news[indexPath.row]
        let url = news.url
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
}
