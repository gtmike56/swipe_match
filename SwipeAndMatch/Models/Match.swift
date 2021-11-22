//
//  Match.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-11.
//

import Foundation

struct Match {
    let name, imageURL1, uid: String
    
    init(matchData: [String: Any]){
        self.name = matchData[FirestoreKeys.name.rawValue] as? String ?? ""
        self.imageURL1 = matchData[FirestoreKeys.image1.rawValue] as? String ?? ""
        self.uid = matchData[FirestoreKeys.uid.rawValue] as? String ?? ""
    }
}
