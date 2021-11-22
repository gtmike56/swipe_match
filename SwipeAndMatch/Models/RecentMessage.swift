//
//  RecentMessage.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-20.
//

import Firebase

struct RecentMessage {
    let uid, name, lastMessage, userImageUrl: String
    let timestamp: Timestamp
    
    init(messageData: [String: Any]){
        self.uid = messageData[FirestoreKeys.uid.rawValue] as? String ?? ""
        self.name = messageData[FirestoreKeys.name.rawValue] as? String ?? ""
        self.lastMessage = messageData[FirestoreKeys.lastMessage.rawValue] as? String ?? ""
        self.userImageUrl = messageData[FirestoreKeys.image1.rawValue] as? String ?? ""
        self.timestamp = messageData[FirestoreKeys.timestamp.rawValue] as? Timestamp ?? Timestamp(date: Date())
    }
}
