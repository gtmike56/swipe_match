//
//  MatchView.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-07.
//

import UIKit
import Firebase

protocol MatchViewDelegate: AnyObject {
    func didTapSendMessage(currentUser: User, matchedUser: Match)
}

final class MatchView: UIView {
    //MARK: - UI Elements
    fileprivate let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let itsAMatchImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "match"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    fileprivate let matchLabel: UILabel = {
        let label = UILabel()
        label.text = "You and someone have liked \neach other"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()
    fileprivate let matchedUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()
    
    fileprivate let sendMessageButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("Send Message", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()
    fileprivate let keepSwipingButton: KeepSwipingButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy fileprivate var views = [currentUserImageView, matchedUserImageView, matchLabel, itsAMatchImageView, sendMessageButton, keepSwipingButton]
    
    //MARK: - Initialization
    var matchedUser: Match?
    weak var delegate: MatchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        blurSetup()
        layoutSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentUser: User! {
        didSet {
            ImageCacheService.shared.loadAppImage(imageURL: currentUser.imageURL1 ?? "") { image in
                if let image = image {
                    self.currentUserImageView.image = image
                }
            }
        }
    }
    
    var matchedUserUID: String! {
        didSet {
            let query = Firestore.firestore().collection(FirestoreCollection.users.rawValue)
            query.document(matchedUserUID).getDocument { snap, error in
                if let error = error {
                    print("Failed to add listner for new sent messages, \(error)")
                    return
                }
                guard let matchedUserData = snap?.data() else { return }
                let matchedUser = Match(matchData: matchedUserData)
                self.matchedUser = matchedUser
                self.matchLabel.text = "You and \(matchedUser.name) have liked \neach other"
                ImageCacheService.shared.loadAppImage(imageURL: matchedUser.imageURL1) { image in
                    if let image = image {
                        self.matchedUserImageView.image = image
                        self.animationsSetup()
                    }
                }
            }
        }
    }
    
    //MARK: - Layout Setup
    fileprivate func layoutSetup(){
        views.forEach { view in
            addSubview(view)
            view.alpha = 0
        }
        
        let imageWidth: CGFloat = 150
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        currentUserImageView.layer.cornerRadius = imageWidth/2
        
        matchedUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, size: .init(width: imageWidth, height: imageWidth))
        matchedUserImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        matchedUserImageView.layer.cornerRadius = imageWidth/2
        
        matchLabel.anchor(top: nil, leading: leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 30, right: 0), size: .init(width: 0, height: 50))
        
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: matchLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 15, right: 0), size: .init(width: 300, height: 180))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let buttonHeight: CGFloat = 60
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 30, left: 50, bottom: 0, right: 50), size: .init(width: 0, height: buttonHeight))
        sendMessageButton.layer.cornerRadius = buttonHeight/2
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 20, left: 50, bottom: 0, right: 50), size: .init(width: 0, height: buttonHeight))
        keepSwipingButton.layer.cornerRadius = buttonHeight/2
    }
    
    fileprivate func blurSetup(){
        blur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))

        addSubview(blur)
        blur.fillSuperview()
        blur.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blur.alpha = 1
        }
    }
    
    //MARK: - Animation
    fileprivate func animationsSetup() {
        views.forEach { $0.alpha = 1 }
        
        //starting positions
        let degrees: CGFloat = 30
        let angle = degrees * .pi/180
        currentUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: 300, y: 0))
        matchedUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: -300, y: 0))
        
        sendMessageButton.transform = CGAffineTransform(translationX: 700, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: -700, y: 0)
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic) {
            //translation
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: angle)
                self.matchedUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            //rotation
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.35) {
                self.currentUserImageView.transform = .identity
                self.matchedUserImageView.transform = .identity
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        }
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleTapDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc fileprivate func handleSendMessage(){
        guard let currentUser = self.currentUser, let matchedUser = self.matchedUser else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.delegate?.didTapSendMessage(currentUser: currentUser, matchedUser: matchedUser)
        }
    }
}
