//
//  Message.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-12.
//

import Firebase

struct Message: Hashable {
    let text, fromID, toID: String
    let timestamp: Timestamp
    let isMessageFromCurrentUser: Bool
    
    init(messageData: [String: Any]){
        self.text = messageData[FirestoreKeys.messageText.rawValue] as? String ?? ""
        self.fromID = messageData[FirestoreKeys.fromUID.rawValue] as? String ?? ""
        self.toID = messageData[FirestoreKeys.toUID.rawValue] as? String ?? ""
        self.timestamp = messageData[FirestoreKeys.timestamp.rawValue] as? Timestamp ?? Timestamp(date: Date())
        self.isMessageFromCurrentUser = Auth.auth().currentUser?.uid == self.fromID
    }
}
