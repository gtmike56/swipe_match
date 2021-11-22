//
//  HomeTopControlsStackView.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-19.
//

import UIKit

final class HomeTopControlsStackView: UIStackView {
    //MARK: - UI Elements
    let profileButton = UIButton(type: .system)
    let fireButton = UIButton(type: .system)
    let chatButton = UIButton(type: .system)
    let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "SWIPE & MATCH"
        label.font = UIFont(name: "IndieFlower", size: 30)
        //label.font = UIFont(name: "Comfortaa-Bold", size: 22)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    //MARK: Initialization
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
        distribution = .equalSpacing
        alignment = .center
        heightAnchor.constraint(equalToConstant: 85).isActive = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        addSubview(logoLabel)
        logoLabel.centerInSuperview()
    }
    
    fileprivate func buttonsSetup(){
        profileButton.setImage(UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        chatButton.setImage(UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        [profileButton, chatButton].forEach { (button) in
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = 30
            button.layer.masksToBounds = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 40),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
            addArrangedSubview(button)
        }
    }
}
