//
//  CustomCollectionViewController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-15.
//

import UIKit
/**
 CustomCollectionViewController helps register, dequeues, and sets up cells with their respective items to render in a standard single section list.
 
 ## Generics ##
 T: the cell type that this list will register and dequeue.
 
 U: the item type that each cell will visually represent.
 
 H: the header type above the section of cells.
 
 F: the footer type below the section of cells
 
 */
class CustomCollectionViewController<T: CustomCollectionViewCell<U>, U, H: UICollectionReusableView, F: UICollectionReusableView>: UICollectionViewController {
    // An array of U objects this list will render
    var items = [U]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate let cellId = "cellId"
    fileprivate let supplementaryViewId = "supplementaryViewId"
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(T.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(H.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: supplementaryViewId)
        collectionView.register(F.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: supplementaryViewId)
    }
    
    init(layout: UICollectionViewLayout = UICollectionViewFlowLayout(), scrollDirection: UICollectionView.ScrollDirection = .vertical) {
        if let layout = layout as? UICollectionViewFlowLayout {
            layout.scrollDirection = scrollDirection
        }
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Return an estimated height for proper indexPath using systemLayoutSizeFitting
    func estimatedCellHeight(for indexPath: IndexPath, cellWidth: CGFloat) -> CGFloat {
        let cell = T()
        let largeHeight: CGFloat = 1000
        cell.frame = .init(x: 0, y: 0, width: cellWidth, height: largeHeight)
        cell.item = items[indexPath.item]
        cell.layoutIfNeeded()
        
        return cell.systemLayoutSizeFitting(.init(width: cellWidth, height: largeHeight)).height
    }
    /// CustomCollectionViewController automatically dequeues your T cell and sets the correct item object on it
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! T
        cell.item = items[indexPath.row]
        cell.parentController = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    ///Avoidin headers and footers for UICollectionViewControllers to be drawn above the scroll bar
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = -1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryViewId, for: indexPath)
        if let header = supplementaryView as? H {
            setupHeader(header: header)
        } else if let footer = supplementaryView as? F {
            setupFooter(footer: footer)
        }
        return supplementaryView
    }
    
    func setupHeader(header: H) {}
    func setupFooter(footer: F) {}
}
