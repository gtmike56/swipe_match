//
//  SettingsTableViewCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-28.
//

import UIKit

final class SettingsTableViewCell: UITableViewCell {
    //MARK: - UI Elements
    let cellTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter "
        return textField
    }()
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate func layoutSetup(){
        contentView.isUserInteractionEnabled = true
        
        cellTextField.translatesAutoresizingMaskIntoConstraints = false
        cellTextField.setLeftPaddingPoints(value: 25)
        cellTextField.setRightPaddingPoints(value: 25)
        addSubview(cellTextField)
        cellTextField.fillSuperview()
    }
}
