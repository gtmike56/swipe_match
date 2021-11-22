//
//  UITextField.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-23.
//

import UIKit

/**
An easy way to setup a padding for UITextView
 */

extension UITextField {
    func setLeftPaddingPoints(value: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
