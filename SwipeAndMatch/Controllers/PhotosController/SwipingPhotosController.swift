//
//  SwippingPhotosController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-03.
//

import UIKit

final class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, PhotoControllerDelegate {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        //disable swipe between photos when in cardView
        if viewMode == .cardView {
            gesturesSetup()
            dataSource = nil
        }
        guard let firstVC = controllers.first else { return }
        setViewControllers([firstVC], direction: .forward, animated: false)
    }
    
    //MARK: - Initialization
    fileprivate let viewMode: SwipingPhotosControllerMode
    fileprivate var controllers = [UIViewController]()
    var imageURLs: [String]! {
        didSet {
            controllers = imageURLs.map({ imageURL -> UIViewController in
                let photoController = PhotoConrtoller(imageURL: imageURL)
                photoController.delegate = self
                return photoController
            })
            guard let firstVC = controllers.first else { return }
            setViewControllers([firstVC], direction: .forward, animated: false)
            barViewsSetup()
        }
    }
    
    init(viewMode: SwipingPhotosControllerMode) {
        self.viewMode = viewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    var topPadding: CGFloat = 10
    fileprivate func barViewsSetup() {
        barsStackView.alpha = 0
        self.imageURLs.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = Colors.barDeselectedColor
            barView.layer.cornerRadius = 1
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.spacing = 5
        barsStackView.distribution = .fillEqually
        view.addSubview(barsStackView)
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        if self.viewMode == .userDetailsView {
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                topPadding += statusBarHeight
            } else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                topPadding += statusBarHeight
            }
        }
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: topPadding, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 3))
    }
    
    //MARK: - Gestures setup
    fileprivate func gesturesSetup(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let toNextPhoto = tapLocation.x > view.frame.width/2 ? true : false
        guard let currentVC = viewControllers?.first else { return }
        if let index = controllers.firstIndex(of: currentVC) {
            barsStackView.arrangedSubviews.forEach ({$0.backgroundColor = Colors.barDeselectedColor})
            var nextIndex = index
            if toNextPhoto {
                nextIndex = min(index+1, controllers.count-1)
            } else {
                nextIndex = max(0, index-1)
            }
            barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            let nextController = controllers[nextIndex]
            setViewControllers([nextController], direction: .forward, animated: false)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 {
            return nil
        }
        return controllers[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 {
            return nil
        }
        return controllers[index+1]
    }
    //MARK: - PageViewController setup
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentVC = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentVC}) {
            barsStackView.arrangedSubviews.forEach ({$0.backgroundColor = Colors.barDeselectedColor})
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    //MARK: - Delegation
    func showBars(){
        barsStackView.alpha = 1
    }
}
