//
//  RecentMessageCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-20.
//

import UIKit

final class RecentMessageCell: CustomCollectionViewCell<RecentMessage> {
    //MARK: - UI Elements
    fileprivate let matchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 90/2
        return imageView
    }()
    fileprivate let matchNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    //MARK: - Initialization
    override var item: RecentMessage! {
        didSet {
            matchNameLabel.text = item.name
            messageLabel.text = item.lastMessage
            ImageCacheService.shared.loadAppImage(imageURL: item.userImageUrl) { image in
                if let image = image {
                    self.matchImageView.image = image
                }
            }
        }
    }
    
    //MARK: - Layout setup
    override func setupViews() {
        NSLayoutConstraint.activate([
            matchImageView.widthAnchor.constraint(equalToConstant: 90),
            matchImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        let vStackView = UIStackView(arrangedSubviews: [matchNameLabel, messageLabel])
        vStackView.axis = .vertical
        let hStackView = UIStackView(arrangedSubviews: [matchImageView, vStackView])
        hStackView.axis = .horizontal
        hStackView.alignment = .center
        hStackView.spacing = 20
        addSubview(hStackView)
        hStackView.fillSuperview()
        hStackView.isLayoutMarginsRelativeArrangement = true
        hStackView.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
        addSeparatorView(leadingAnchor: matchNameLabel.leadingAnchor)
    }
}
