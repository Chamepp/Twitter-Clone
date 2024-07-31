//
//  TweetService.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/17/24.
//

import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = [
            "uid": uid,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0,
            "caption": caption
        ] as [String: Any]
        
        switch type {
        case .tweet:
            REF_TWEETS.childByAutoId().updateChildValues(values) { err, ref in
                guard let tweetID = ref.key else { return }
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId().updateChildValues(values) { err, ref in
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_TWEETS.observe(.value) { snapshot in
            var updatedTweets = [Tweet]()
            
            guard let tweetSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for tweetSnapshot in tweetSnapshots {
                let tweetID = tweetSnapshot.key
                dispatchGroup.enter()
                
                self.fetchTweet(withTweetID: tweetID) { tweet in
                    updatedTweets.append(tweet)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                tweets = updatedTweets
                completion(tweets)
            }
        }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.value) { snapshot in
            guard let followingUids = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for followingUidSnapshot in followingUids {
                let followingUid = followingUidSnapshot.key
                let userTweetsRef = REF_USER_TWEETS.child(followingUid)
                
                dispatchGroup.enter()
                
                userTweetsRef.observe(.value) { snapshot in
                    guard let tweetSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    for tweetSnapshot in tweetSnapshots {
                        let tweetID = tweetSnapshot.key
                        dispatchGroup.enter()
                        
                        self.fetchTweet(withTweetID: tweetID) { tweet in
                            tweets.append(tweet)
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var replies = [Tweet]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetKey, dictionary: dictionary)
                    replies.append(tweet)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchRetweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_RETWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            REF_USER_RETWEETS.child(user.uid).child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let retweetTimestamp = dictionary["retweetTimestamp"] as? Double
                
                self.fetchTweet(withTweetID: tweetID) { retweetedTweet in
                    var tweet = retweetedTweet
                    tweet.didRetweet = true
                    
                    if let timestampDouble = retweetTimestamp {
                        tweet.retweetTimestamp = Date(timeIntervalSince1970: TimeInterval(timestampDouble))
                    }
                    
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    
    func likeTweets(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { err, ref in
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func retweetTweets(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let retweets = tweet.didRetweet ? tweet.retweetCount - 1 : tweet.retweetCount + 1
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        REF_TWEETS.child(tweet.tweetID).child("retweets").setValue(retweets)
        
        if tweet.didRetweet {
            REF_USER_RETWEETS.child(uid).child(tweet.tweetID).removeValue { err, ref in
                REF_TWEET_RETWEETS.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            let values: [String: Any] = [
                        "retweetTimestamp": timestamp
                    ]
            
            REF_USER_RETWEETS.child(uid).updateChildValues([tweet.tweetID: 1]) { err, ref in
                REF_USER_RETWEETS.child(uid).child(tweet.tweetID).updateChildValues(values)
                REF_TWEET_RETWEETS.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func checkIfUserRetweetedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_RETWEETS.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
