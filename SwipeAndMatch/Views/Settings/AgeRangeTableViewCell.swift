//
//  AgeRangeTableViewCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-30.
//

import UIKit

final class AgeRangeTableViewCell: UITableViewCell {
    //MARK: - UI Elements
    let minLabel: UILabel = {
        let label = UILabel()
        label.text = "Min 18"
        return label
    }()
    let maxLabel: UILabel = {
        let label = UILabel()
        label.text = "Max 50"
        return label
    }()
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = Float(Helper.minAge)
        slider.maximumValue = Float(Helper.maxAge)
        slider.value = Float(Helper.minAge)
        return slider 
    }()
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = Float(Helper.minAge)
        slider.maximumValue = Float(Helper.maxAge)
        slider.value = Float(Helper.maxAge)
        return slider
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
        
        let topStackView = UIStackView(arrangedSubviews: [minLabel, minSlider])
        topStackView.spacing = 15
        
        let bottomStackView = UIStackView(arrangedSubviews: [maxLabel, maxSlider])
        bottomStackView.spacing = 15
        
        let mainStackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 15
        
        addSubview(mainStackView)
        mainStackView.fillSuperview(padding: .init(top: 15, left: 15, bottom: 15, right: 15))
    }
}
