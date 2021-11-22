//
//  CardView.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-20.
//

import UIKit

protocol CardViewDelegate: AnyObject {
    func didUserDetailsTapped(cardViewModel: CardViewModel)
    func didLike()
    func didDislike()
}

final class CardView: UIView {
    //MARK: - UI Elements
    fileprivate let swipingPhotosController = SwipingPhotosController(viewMode: .cardView)
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    fileprivate let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "info")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDetailsTapped), for: .touchUpInside)
        return button
    }()
         
    //MARK: - Initialization
    weak var delegate: CardViewDelegate?
    var nextCardView: CardView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
        gesturesSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotosController.imageURLs = cardViewModel.imageURLs
            informationLabel.attributedText = cardViewModel.attributedString
        }
    }
    
    //MARK: - Layout Setup
    fileprivate func layoutSetup() {
        clipsToBounds = true
        layer.cornerRadius = 15
        setUpGradientLayer()
        
        addSubview(swipingPhotosController.view)
        swipingPhotosController.view.fillSuperview()
                
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 15, bottom: 15, right: 15))
        
        addSubview(infoButton)
        infoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 40, right: 20), size: .init(width: 45, height: 45))
    }
    
    fileprivate func setUpGradientLayer(){
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = frame
    }
    
    //MARK: - Gestures Setup
    fileprivate func gesturesSetup(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ cardView in
                cardView.layer.removeAllAnimations()
            })
        case .changed:
            handleChangedState(gesture)
        case .ended:
            handleEndedState(gesture)
        default:
            ()
        }
    }
    
    fileprivate func handleChangedState(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x/20
        let angle = degrees * .pi/180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handleEndedState(_ gesture: UIPanGestureRecognizer) {
        let threshold: CGFloat = 100
        let shouldDismissCard = gesture.translation(in: nil).x > threshold || gesture.translation(in: nil).x < -threshold
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            if shouldDismissCard && gesture.translation(in: nil).x > 0 {
                self.delegate?.didLike()
                self.transform = self.transform.translatedBy(x: 700, y: 0)
            } else if shouldDismissCard && gesture.translation(in: nil).x < 0 {
                self.delegate?.didDislike()
                self.transform = self.transform.translatedBy(x: -700, y: 0)
            } else {
                self.transform = .identity
            }
        }
    }
    
    //MARK: - Delegation
    @objc fileprivate func handleDetailsTapped(){
        delegate?.didUserDetailsTapped(cardViewModel: self.cardViewModel)
    }
}
