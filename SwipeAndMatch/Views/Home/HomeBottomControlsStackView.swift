//
//  HomeBottomControlsStackView.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-19.
//

import UIKit

final class HomeBottomControlsStackView: UIStackView {
    //MARK: - UI Elements
    let refreshButton = UIButton(type: .system)
    let dislikeButton = UIButton(type: .system)
    let likeButton = UIButton(type: .system)
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
        buttonsSetup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup(){
        distribution = .equalCentering
        alignment = .center
        heightAnchor.constraint(equalToConstant: 120).isActive = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    fileprivate func buttonsSetup(){
        refreshButton.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysOriginal), for: .normal)
        dislikeButton.setImage(UIImage(named: "dislike")?.withRenderingMode(.alwaysOriginal), for: .normal)
        likeButton.setImage(UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        [refreshButton, likeButton, dislikeButton].forEach { (button) in
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = 25
            button.layer.masksToBounds = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 55),
                button.heightAnchor.constraint(equalToConstant: 55)
            ])
            addArrangedSubview(button)
        }
    }
}
