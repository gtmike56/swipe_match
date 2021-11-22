//
//  CustomCollectionViewCell.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-15.
//

import UIKit
/**
 CustomCollectionViewCell presents a cell that CustomCollectionViewController registers and dequeues for list rendering. T represents the Class Type this cell should render visually.
 
 ## Generics ##
 T: the cell type that this list will register and dequeue.
 */
class CustomCollectionViewCell<T>: UICollectionViewCell {
    ///In case I need to add a target to a button
    weak var parentController: UIViewController?
    ///Automatically fed from CustomCollectionViewCell
    var item: T!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// To avoid overriding init methods simply override this method to setup views in the cell
    func setupViews() {}
    
    /// Separators for cell. Using it almost in every project so usefull to have
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
        return view
    }()
    func addSeparatorView(leadingAnchor: NSLayoutXAxisAnchor) {
        addSubview(separatorView)
        separatorView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    func addSeparatorView(leftPadding: CGFloat = 0) {
        addSubview(separatorView)
        separatorView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: leftPadding, bottom: 0, right: 0), size: .init(width: 0, height: 0.5))
    }
    
    
}
