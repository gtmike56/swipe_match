//
//  KeepSwipingButton.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-07.
//

import UIKit

final class KeepSwipingButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradient = CAGradientLayer()
        let leftColor = Colors.gradientStart
        let rightColor = Colors.gradientEnd
        gradient.colors = [leftColor.cgColor, rightColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2).cgPath)
        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 3, dy: 3), cornerRadius: rect.height/2).cgPath)
        
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        gradient.mask = maskLayer
        
        self.layer.insertSublayer(gradient, at: 0)
        gradient.frame = rect
    }
}
