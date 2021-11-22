//
//  CardViewModel.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-21.
//

import UIKit

final class CardViewModel {
    let uid: String
    var imageURLs: [String]
    let attributedString: NSMutableAttributedString
    let bio: String
    
    
    init(user: User) {
        self.uid = user.uid
        self.imageURLs = []
        if let image1 = user.imageURL1 {
            self.imageURLs.append(image1)
        }
        if let image2 = user.imageURL2 {
            self.imageURLs.append(image2)
        }
        if let image3 = user.imageURL3 {
            self.imageURLs.append(image3)
        }
        let attributedText = NSMutableAttributedString(string: user.name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 30, weight: .heavy)])
        let ageString = user.age != nil ? "  \(user.age!)" : "  N/A"
        let occupationString = user.occupation != nil ? "\n\(user.occupation!)" : "\nNot Available"
        attributedText.append(NSMutableAttributedString(string: ageString, attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .medium)]))
        attributedText.append(NSMutableAttributedString(string: occupationString, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .medium)]))
        self.attributedString = attributedText
        self.bio = user.bio ?? "No bio"
    }
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageName = imageURLs[imageIndex]
            ImageCacheService.shared.loadAppImage(imageURL: imageName) { image in
                self.imageIndexObserver?(self.imageIndex, image)
            }
        }
    }
    var imageIndexObserver: ((Int, UIImage?) -> ())?

    func goToNextPhoto(){
        imageIndex = min(imageIndex + 1, imageURLs.count - 1)
    }
    
    func goToPreviousPhoto(){
        imageIndex = max(0, imageIndex - 1)
    }
}
