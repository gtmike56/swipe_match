//
//  UserDetailsController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-02.
//

import Foundation
import UIKit

protocol UserDetailsControllerDelegate: AnyObject {
    func didDislike()
    func didLike()
}

final class UserDetailsController: UIViewController, UIScrollViewDelegate, UIPageViewControllerDelegate {
    //MARK: - UI Elements
    lazy fileprivate var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()
    fileprivate let headerPhotosPageController = SwipingPhotosController(viewMode: .userDetailsView)
    fileprivate let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    fileprivate let bioLabel: UITextView = {
        let label = UITextView()
        label.isUserInteractionEnabled = false
        label.textColor = .black
        label.isScrollEnabled = true
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textContainer.maximumNumberOfLines = 7
        label.textContainer.lineBreakMode = .byTruncatingTail
        return label
    }()
    fileprivate let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "downArrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissTapped), for: .touchUpInside)
        return button
    }()
    
    lazy fileprivate var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [informationLabel, dismissButton])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        return stackView
    }()
    
    lazy fileprivate var dislikeButton = self.createButton(image: UIImage(named: "dislike"), selector: #selector(handleDislike))
    lazy fileprivate var likeButton = self.createButton(image: UIImage(named: "heart"), selector: #selector(handleLike))
    
    lazy fileprivate var controlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeButton, dislikeButton])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 50, bottom: 0, right: 50)
        return stackView
    }()
    
    lazy fileprivate var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView, bioLabel, controlsStackView])
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        blurEffectViewSetup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerPhotosPageController.showBars()
        headerPhotosPageController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width+extraHeaderHeight)
    }
    
    //MARK: - Initialization
    weak var delegate: UserDetailsControllerDelegate?
    var cardViewModel: CardViewModel! {
        didSet {
            informationLabel.attributedText = cardViewModel.attributedString
            headerPhotosPageController.imageURLs = cardViewModel.imageURLs
            bioLabel.text = cardViewModel.bio
        }
    }
    
    //MARK: - Layout Setup
    fileprivate let extraHeaderHeight: CGFloat = 75
    fileprivate func layoutSetup() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 45),
            dismissButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        scrollView.addSubview(headerPhotosPageController.view)
        
        scrollView.addSubview(mainStackView)
        mainStackView.anchor(top: headerPhotosPageController.view.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 15, left: 15, bottom: 0, right: 15))
        
        bioLabel.heightAnchor.constraint(equalToConstant: 165).isActive = true
        
    }
    
    fileprivate func blurEffectViewSetup(){
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func createButton(image: UIImage?, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = false
        button.widthAnchor.constraint(equalToConstant: 45).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = scrollView.contentOffset.y
        let width = max(view.frame.width, view.frame.width - changeY * 2)
        headerPhotosPageController.view.frame = CGRect(x: min(0, changeY), y: min(0, changeY), width: width, height: width+extraHeaderHeight)
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleDismissTapped(){
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleDislike(){
        self.dismiss(animated: true, completion: delegate?.didDislike)
    }

    @objc fileprivate func handleLike(){
        self.dismiss(animated: true, completion: delegate?.didLike)
    }
}
