//
//  ProfileController.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/21/24.
//

import Firebase
import UIKit

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    // MARK: - Properties
    var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var tweets = [Tweet]()
    private lazy var likedTweets = [Tweet]()
    private lazy var retweetedTweets = [Tweet]()
    private lazy var replies = [Tweet]()
    
    private lazy var combinedTweets = [Tweet]()
    
    private var tweetsFetched = false
    private var retweetsFetched = false
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return combinedTweets
        case .replies: return replies
        case .likes: return likedTweets
        }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchTweets()
        fetchRetweetedTweets()
        fetchLikedTweets()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUserStats()
        mergeTweetsAndRetweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - API
    func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.tweetsFetched = true
            self.checkIfUserLikedTweets(in: self.tweets) { updatedTweets in
                self.tweets = updatedTweets
            }
            self.checkIfDataFetched()
            self.collectionView.reloadData()
        }
    }
    
    func fetchLikedTweets() {
        TweetService.shared.fetchLikes(forUser: user) { tweets in
            self.likedTweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserRetweetedTweets(in: self.likedTweets) { updatedTweets in
                self.likedTweets = updatedTweets
            }
            self.checkIfDataFetched()
            self.collectionView.reloadData()
        }
    }
    
    func fetchRetweetedTweets() {
        TweetService.shared.fetchRetweets(forUser: user) { tweets in
            self.retweetedTweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.retweetsFetched = true
            self.checkIfDataFetched()
        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserLikedTweets(in tweets: [Tweet], completion: @escaping ([Tweet]) -> Void) {
        var updatedTweets = tweets
        let dispatchGroup = DispatchGroup()

        for (index, tweet) in tweets.enumerated() {
            dispatchGroup.enter()
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                if didLike {
                    updatedTweets[index].didLike = true
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(updatedTweets)
        }
    }
    
    func checkIfUserRetweetedTweets(in tweets: [Tweet], completion: @escaping ([Tweet]) -> Void) {
        var updatedTweets = tweets
        let dispatchGroup = DispatchGroup()

        for (index, tweet) in tweets.enumerated() {
            dispatchGroup.enter()
            TweetService.shared.checkIfUserRetweetedTweet(tweet) { didRetweet in
                if didRetweet {
                    updatedTweets[index].didRetweet = true
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(updatedTweets)
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    // MARK: - Selectors
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
    
    func mergeTweetsAndRetweets() {
        combinedTweets = (tweets + retweetedTweets).sorted(by: { (firstTweet, secondTweet) -> Bool in
                if let firstRetweetTimestamp = firstTweet.retweetTimestamp, let secondRetweetTimestamp = secondTweet.retweetTimestamp {
                    // Both are retweets, compare retweet timestamps
                    return firstRetweetTimestamp > secondRetweetTimestamp
                } else if let firstRetweetTimestamp = firstTweet.retweetTimestamp {
                    // First is a retweet, second is a tweet, compare retweet timestamp with tweet timestamp
                    return firstRetweetTimestamp > secondTweet.timestamp
                } else if let secondRetweetTimestamp = secondTweet.retweetTimestamp {
                    // Second is a retweet, first is a tweet, compare tweet timestamp with retweet timestamp
                    return firstTweet.timestamp > secondRetweetTimestamp
                } else {
                    // Both are tweets, compare tweet timestamps
                    return firstTweet.timestamp > secondTweet.timestamp
                }
            })
        collectionView.reloadData()
    }
    
    func checkIfDataFetched() {
        if tweetsFetched || retweetsFetched {
            mergeTweetsAndRetweets()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.frame.width).height
        
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func logUserOut() {
        AlertManager.shared.presentLogoutAlert(
            onController: self,
            title: "Log Out",
            message: "Are you sure you want to log out? You will need to log in again to access your account."
        ) {
            do {
                try Auth.auth().signOut()

                DispatchQueue.main.async {
                    let nav = UINavigationController(rootViewController: LoginController())
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            } catch let error {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleEditProfileButton(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let nav = Utilities().templateNavigationController(image: nil, rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { ref, err in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(type: .follow, user: self.user)
            }
        }
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditProfileControllerDelegate
extension ProfileController: EditProfileControllerDelegate {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
}
