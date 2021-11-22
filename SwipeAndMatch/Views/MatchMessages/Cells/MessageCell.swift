//
//  MessageCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-17.
//

import UIKit

final class MessageCell: CustomCollectionViewCell<Message> {
    //MARK: - UI Elements
    fileprivate let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    fileprivate let bubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    //MARK: - Layout setup
    override func setupViews() {
        addSubview(bubble)
        bubbleConstraints = bubble.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        bubbleConstraints?.leading?.constant = 20
        bubbleConstraints?.trailing?.constant = -20
        bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 260).isActive = true
        
        bubble.addSubview(messageTextView)
        messageTextView.fillSuperview(padding: .init(top: 5, left: 10, bottom: 5, right: 10))
    }
    
    fileprivate var bubbleConstraints: AnchoredConstraints?
    
    //MARK: - Initialization
    override var item: Message! {
        didSet {
            guard let bubbleConstraints = bubbleConstraints else { return }
            messageTextView.text = item.text
            if item.isMessageFromCurrentUser {
                //sent message
                bubbleConstraints.leading?.isActive = false
                bubbleConstraints.trailing?.isActive = true
                bubble.backgroundColor = Colors.gradientEnd
                messageTextView.textColor = .white
            } else {
                //received message
                bubbleConstraints.leading?.isActive = true
                bubbleConstraints.trailing?.isActive = false
                bubble.backgroundColor = UIColor(white: 0.95, alpha: 1)
                messageTextView.textColor = .black
            }
        }
    }
}
