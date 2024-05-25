//
//  Constants.swift
//  Twitter-Clone
//
//  Created by Ashkan Ebtekari on 5/11/24.
//

import Firebase

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

let REF_TWEETS = REF_USERS.child("tweets")
let REF_USER_TWEETS = DB_REF.child("user-tweets")
