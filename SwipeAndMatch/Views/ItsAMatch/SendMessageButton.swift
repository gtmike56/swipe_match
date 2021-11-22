//
//  SendMessageButton.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-07.
//

import UIKit

final class SendMessageButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradient = CAGradientLayer()
        let leftColor = Colors.gradientStart
        let rightColor = Colors.gradientEnd
        gradient.colors = [leftColor.cgColor, rightColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.insertSublayer(gradient, at: 0)
        gradient.frame = rect
    }
}
