//
//  AlertController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-27.
//

import Foundation
import UIKit

final class Helper {
    //MARK: - UI Elements
    static func makeActivityAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = .large
        } else {
            loadingIndicator.style = .gray
        }
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        return alert
    }
    
    static func makeErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
    
    //MARK: - Confoguration
    static let minAge = 18
    static let maxAge = 80
}
