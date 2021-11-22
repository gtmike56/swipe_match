//
//  Enums.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-20.
//

import UIKit

//MARK: - Firestore dictionary keys
enum FirestoreKeys: String {
    case uid = "uid"
    case name = "name"
    case age = "age"
    case occupation = "occupation"
    case bio = "bio"
    case image1 = "imageURL1"
    case image2 = "imageURL2"
    case image3 = "imageURL3"
    case minSeekAge = "minSeekAge"
    case maxSeekAge = "maxSeekAge"
    case messageText = "messageText"
    case fromUID = "fromUID"
    case toUID = "toUID"
    case timestamp = "timestamp"
    case lastMessage = "lastMessage"
}

//MARK: - Firestore collection names
enum FirestoreCollection: String {
    case users = "users"
    case matches = "matches"
    case swipes = "swipes"
    case matches_messages = "matches_messages"
    case recent_messages = "recent_messages"
    case timestamp = "timestamp"
}

    
enum SwipingPhotosControllerMode {
    case cardView, userDetailsView
}
