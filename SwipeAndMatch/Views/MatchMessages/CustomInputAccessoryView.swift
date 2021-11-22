//
//  CustomInputAccessoryView.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-17.
//

import UIKit

final class CustomInputAccessoryView: UIView {
    //MARK: - UI Elements
    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Start typing"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        return textView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.tintColor = .lightGray
        return button
    }()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup(){
        backgroundColor = .white
        layer.shadowOpacity = 0.1
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .init(width: 0, height: -10)
        autoresizingMask = .flexibleHeight
        
        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(equalToConstant: 60),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [textView, sendButton])
        stackView.alignment = .center
        addSubview(stackView)
        stackView.fillSuperview()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        placeholderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
    }
    
    func resetAccessoryView() {
        placeholderLabel.alpha = 1
        sendButton.isEnabled = false
        sendButton.tintColor = .lightGray
    }
    
    @objc fileprivate func handleTextChange() {
        if textView.text != "" {
            placeholderLabel.alpha = 0
            sendButton.isEnabled = true
            sendButton.tintColor = Colors.gradientEnd
        } else {
            resetAccessoryView()
        }
    }
}
