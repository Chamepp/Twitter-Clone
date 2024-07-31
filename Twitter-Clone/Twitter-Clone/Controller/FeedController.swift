//
//  FeedController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/4/24.
//


import UIKit
import SDWebImage

private let reuseIdentifier = "Tweet Cell"

class FeedController: UICollectionViewController {
    // MARK: - Properties
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
            activityIndicator.stopAnimating()
            checkIfTweetsAvailable(for: &self.tweets)
        }
    }
    
    private let noTweetsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "not_available")
        iv.isHidden = true
        return iv
    }()
    
    private let noTweetsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Tweets Available"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.isHidden = true
        return label
    }()
    
    private let noTweetsDescription: UILabel = {
        let label = UILabel()
        label.text = "Consider following some people \nfrom the explore tab"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchTweets()
        scheduleNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    // MARK: - API
    @objc func fetchTweets() {
        activityIndicator.startAnimating()
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()
            self.checkIfUserRetweetedTweets()
            
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    func checkIfUserRetweetedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserRetweetedTweet(tweet) { didRetweet in
                guard didRetweet == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didRetweet = true
                }
            }
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(activityIndicator)
        activityIndicator.center(inView: view)
        
        let labelStack = UIStackView(arrangedSubviews: [noTweetsImageView, noTweetsLabel, noTweetsDescription])
        labelStack.axis = .vertical
        labelStack.spacing = 10
        
        view.addSubview(labelStack)
        labelStack.center(inView: view)
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .twitterBlue
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        // Initial state of the cell (before animation)
        profileImageView.alpha = 0
        
        // Animate to the final state (after animation)
        UIView.animate(withDuration: 0.5) {
            profileImageView.alpha = 1
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        }
    }
    
    func scheduleNotification() {
        PushNotificationManager.shared.scheduleNotification(identifier: .appActivity)
    }
    
    func checkIfTweetsAvailable(for tweets: inout [Tweet]) {
        noTweetsLabel.isHidden = !tweets.isEmpty
        noTweetsDescription.isHidden = !tweets.isEmpty
        noTweetsImageView.isHidden = !tweets.isEmpty
    }
}

// MARK: - UICollectionViewDelegate/DataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

// MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweets(tweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(type: .like, tweet: tweet)
        }
    }
    
    func handleRetweetTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.retweetTweets(tweet: tweet) { err, ref in
            cell.tweet?.didRetweet.toggle()
            let retweets = tweet.didRetweet ? tweet.retweetCount - 1 : tweet.retweetCount + 1
            cell.tweet?.retweetCount = retweets
            
            guard !tweet.didRetweet else { return }
            NotificationService.shared.uploadNotification(type: .retweet, tweet: tweet)
        }
    }
    
    func handleShareTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        ActivityManager.shared.presentActivity(onController: self, for: tweet.tweetID)
    }
}
