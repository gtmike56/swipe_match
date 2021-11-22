//
//  MatchesHeader.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-19.
//

import UIKit

final class MatchesHeader: UICollectionReusableView {
    //MARK: - UI Elements
    fileprivate let newMatchesLabel: UILabel = {
        let label = UILabel()
        label.text = "New Matches"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Colors.gradientEnd
        return label
    }()
    
    let matchesHorizontalController = MatchesHorizontalController()
    
    fileprivate let messagesLabel: UILabel = {
        let label = UILabel()
        label.text = "Messages"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Colors.gradientEnd
        return label
    }()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup(){
        let matchesLabelStackView = UIStackView(arrangedSubviews: [newMatchesLabel])
        matchesLabelStackView.isLayoutMarginsRelativeArrangement = true
        matchesLabelStackView.layoutMargins.left = 15
        let messagesLabelStackView = UIStackView(arrangedSubviews: [messagesLabel])
        messagesLabelStackView.isLayoutMarginsRelativeArrangement = true
        messagesLabelStackView.layoutMargins.left = 15
        let stackView = UIStackView(arrangedSubviews: [matchesLabelStackView, matchesHorizontalController.view, messagesLabelStackView])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 15, left: 0, bottom: 0, right: 0)
        
        addSubview(stackView)
        stackView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
