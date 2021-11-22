//
//  PhotoController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-03.
//

import UIKit

protocol PhotoControllerDelegate: AnyObject {
    func showBars()
}

final class PhotoConrtoller: UIViewController {
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.fillSuperview()
    }
    
    
    //MARK: - Initialization
    let imageView = UIImageView()
    weak var delegate: PhotoControllerDelegate?

    init(imageURL: String) {
        super.init(nibName: nil, bundle: nil)
        ImageCacheService.shared.loadAppImage(imageURL: imageURL) { image in
            if let image = image {
                self.imageView.image = image
                self.delegate?.showBars()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
