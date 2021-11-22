//
//  MatchCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-17.
//

import UIKit

final class MatchCell: CustomCollectionViewCell<Match> {
    //MARK: - UI Elements
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 85 / 2
        return imageView
    }()
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Text"
        label.font = .systemFont(ofSize: 16 , weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    //MARK: - Layout setup
    override func setupViews() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 85),
            profileImageView.heightAnchor.constraint(equalToConstant: 85)
        ])
        
        let supportStackView = UIStackView(arrangedSubviews: [profileImageView])
        supportStackView.alignment = .center
        supportStackView.axis = .vertical
        let stackView = UIStackView(arrangedSubviews: [supportStackView, nameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.fillSuperview()
    }
    
    //MARK: - Initialization
    override var item: Match! {
        didSet {
            nameLabel.text = item.name
            ImageCacheService.shared.loadAppImage(imageURL: item.imageURL1) { image in
                if let image = image {
                    self.profileImageView.image = image
                }
            }
        }
    }
}
