//
//  User.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-20.
//

import UIKit

struct User {
    var uid: String
    var name, occupation, bio, imageURL1, imageURL2, imageURL3: String?
    var age, minSeekAge, maxSeekAge: Int?
    
    init(userInfo: [String: Any]) {
        self.uid = userInfo[FirestoreKeys.uid.rawValue] as? String ?? "uid"
        self.name = userInfo[FirestoreKeys.name.rawValue] as? String
        if let age = userInfo[FirestoreKeys.age.rawValue] as? Int {
            if age < Helper.minAge {
                self.age = Helper.minAge
            }
            if age > Helper.maxAge {
                self.age = Helper.maxAge
            } else {
                self.age = age
            }
        }
        self.occupation = userInfo[FirestoreKeys.occupation.rawValue] as? String
        self.bio = userInfo[FirestoreKeys.bio.rawValue] as? String
        self.imageURL1 = userInfo[FirestoreKeys.image1.rawValue] as? String
        self.imageURL2 = userInfo[FirestoreKeys.image2.rawValue] as? String
        self.imageURL3 = userInfo[FirestoreKeys.image3.rawValue] as? String
        self.minSeekAge = userInfo[FirestoreKeys.minSeekAge.rawValue] as? Int
        self.maxSeekAge = userInfo[FirestoreKeys.maxSeekAge.rawValue] as? Int
    }
}
