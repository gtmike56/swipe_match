//
//  MessagesNavBar.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-15.
//

import UIKit

final class MessagesNavBar: UIView {
    //MARK: UI Elements
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "left")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    fileprivate let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup() {
        backgroundColor = .white
        
        layer.shadowColor = UIColor.init(white: 0, alpha: 0.3).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: 10)
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: 20, bottom: 0, right: 0), size: .init(width: 35, height: 35))
        
        addSubview(chatImageView)
        chatImageView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: nil, bottom: bottomAnchor, trailing: nil, padding: .init(top: 15, left: 0, bottom: 15, right: 0),size: .init(width: 45, height: 45))
        chatImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
