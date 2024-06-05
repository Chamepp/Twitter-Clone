//
//  ActionSheetViewModel.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 6/4/24.
//

import UIKit

struct ActionSheetViewModel {
    // MARK: - Properties
    private let user: User
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.report)
        
        return results
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
    }
    
    // MARK: - API
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    func configureUI() {
        
    }
}

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user): return "Follow @\(user.username)"
        case .unfollow(let user): return "Unfollow @\(user.username)"
        case .report: return "Report Tweet"
        case .delete: return "Delete Tweet"
        }
    }
}
