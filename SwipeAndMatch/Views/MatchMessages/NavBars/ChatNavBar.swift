//
//  ChatNavBar.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-16.
//

import UIKit

final class ChatNavBar: UIView {
    //MARK: UI Elements
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "left")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    let supportButton = UIButton()
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 45/2
        return imageView
    }()
    
    //MARK: - Initialization
    fileprivate let match: Match
    init(match: Match) {
        self.match = match
        super.init(frame: .zero)
        nameLabel.text = match.name
        ImageCacheService.shared.loadAppImage(imageURL: match.imageURL1) { image in
            if let image = image {
                self.profileImageView.image = image
            }
        }
        layoutSetup()
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup() {
        backgroundColor = .white
        
        layer.shadowColor = UIColor.init(white: 0, alpha: 0.3).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: 10)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 35),
            supportButton.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45)
        ])
        
        let proflleStack = UIStackView(arrangedSubviews: [profileImageView, nameLabel])
        proflleStack.axis = .vertical
        proflleStack.alignment = .center
        proflleStack.spacing = 5
        
        let supportProfileStack = UIStackView(arrangedSubviews: [proflleStack])
        supportProfileStack.axis = .horizontal
        supportProfileStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [backButton, supportProfileStack, supportButton])
        mainStack.axis = .horizontal
        addSubview(mainStack)
        mainStack.fillSuperview(padding: .init(top: 0, left: 15, bottom: 0, right: 15))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
