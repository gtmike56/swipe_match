//
//  ViewController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-19.
//

import UIKit
import Firebase
import SwiftUI

final class HomeViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate, UserDetailsControllerDelegate, MatchViewDelegate {
    fileprivate var cardViewModels = [CardViewModel]()
    fileprivate var currentUser: User?
    fileprivate var topCardView: CardView?
    fileprivate var currentUserSwipes = [String : Int]()
    fileprivate var fetchedUsersDictionary = [String: User]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        buttonsSetup()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navigationController = UINavigationController(rootViewController: loginController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    //MARK: - UI Views
    fileprivate let topView = HomeTopControlsStackView()
    fileprivate let cardsDeckView = UIView()
    fileprivate let bottomView = HomeBottomControlsStackView()
    fileprivate let activity = Helper.makeActivityAlert(message: "Loading...")
    
    //MARK: - Layout Setup
    fileprivate func layoutSetup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        let mainStackView = UIStackView(arrangedSubviews: [topView, cardsDeckView, bottomView])
        mainStackView.axis = .vertical
        
        view.addSubview(mainStackView)
        mainStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        mainStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func buttonsSetup() {
        //top controllers
        topView.profileButton.addTarget(self, action: #selector(handleProfile), for: .touchUpInside)
        topView.chatButton.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        //bottom controllers
        bottomView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    }
    
    //MARK: - User cards setup
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(uid).getDocument { snapShot, error in
            if let error = error {
                print("Failed to fetch current user, \(error)")
                self.activity.dismiss(animated: false) {
                    self.present(Helper.makeErrorAlert(title: "Registration Error", message: error.localizedDescription), animated: true)
                }
                return
            }
            guard let userData = snapShot?.data() else { return }
            let user = User(userInfo: userData)
            self.currentUser = user
            self.fetchSwipes()
        }
    }
    
    fileprivate func fetchSwipes(){
        currentUserSwipes.removeAll()
        guard let uid = self.currentUser?.uid else { return }
        Firestore.firestore().collection(FirestoreCollection.swipes.rawValue).document(uid).getDocument { snap, error in
            if let error = error {
                print("Failed to fetch swipes, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            guard let swipesData = snap?.data() as? [String : Int] else {
                self.fetchUsersFromFirestore()
                return
            }
            self.currentUserSwipes = swipesData
            self.fetchUsersFromFirestore()
        }
    }
    
    fileprivate func fetchUsersFromFirestore() {
        present(activity, animated: true)
        let minSeekAge = self.currentUser?.minSeekAge
        let maxSeekAge = self.currentUser?.maxSeekAge
        let query = Firestore.firestore().collection(FirestoreCollection.users.rawValue).whereField(FirestoreKeys.age.rawValue, isGreaterThanOrEqualTo: minSeekAge ?? Helper.minAge).whereField(FirestoreKeys.age.rawValue, isLessThanOrEqualTo: maxSeekAge ?? Helper.maxAge)
        topCardView = nil
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch users for swipe cards \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            
            var prevCardView: CardView?
            snapshot?.documents.forEach({ documentSnapshot in
                let userDictionaty = documentSnapshot.data() 
                let user = User(userInfo: userDictionaty)
                self.fetchedUsersDictionary[user.uid] = user
                let isCurrentUser = user.uid == self.currentUser?.uid
                //uncomment to never show swiped users
                //let wasSwiped = self.currentUserSwipes[user.uid] != nil
                if !isCurrentUser {//&& !wasSwiped {
                    let cardView = self.setupCardFromUser(user: user)
                    prevCardView?.nextCardView = cardView
                    prevCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
            self.activity.dismiss(animated: true)
        }
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardViewModel = CardViewModel(user: user)
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = cardViewModel
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    fileprivate func removeAllCards(){
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    //MARK: - Swipe Saving
    fileprivate func saveSwipe(isLike: Bool) {
        guard let path = currentUser?.uid, let swipedUserUID = topCardView?.cardViewModel.uid else { return }
        let swipeData: [String : Any] = [swipedUserUID: isLike ? 1 : 0]
        
        Firestore.firestore().collection(FirestoreCollection.swipes.rawValue).document(path).getDocument { snap, error in
            if let error = error {
                print("Failed to fetch swipe, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            
            if snap?.exists == true {
                Firestore.firestore().collection(FirestoreCollection.swipes.rawValue).document(path).updateData(swipeData) { error in
                    if let error = error {
                        print("Failed to update the swipe data, \(error)")
                        self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                        return
                    }
                    if isLike {
                        self.checkForMatch(swipedUserUID: swipedUserUID)
                    }
                }
            } else {
                Firestore.firestore().collection(FirestoreCollection.swipes.rawValue).document(path).setData(swipeData) { error in
                    if let error = error {
                        print("Failed to upload the swipe data, \(error)")
                        self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                        return
                    }
                    if isLike {
                        self.checkForMatch(swipedUserUID: swipedUserUID)
                    }
                }
            }
        }
    }
    
    fileprivate func cardSwipe(translationX: CGFloat, digree: CGFloat){
        let animationDuration = 0.9
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translationX
        translationAnimation.duration = animationDuration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = animationDuration
        let degrees: CGFloat = digree
        let angle = degrees * .pi/180
        rotationAnimation.toValue = angle
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(rotationAnimation, forKey: "transform.rotation.z")
        cardView?.layer.add(translationAnimation, forKey: "position.x")
        CATransaction.commit()
    }
    
    //MARK: - Detecting a match
    fileprivate func checkForMatch(swipedUserUID: String) {
        Firestore.firestore().collection(FirestoreCollection.swipes.rawValue).document(swipedUserUID).getDocument { snap, error in
            if let error = error {
                print("Failed to fetch swipe info, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            guard let swipedUserSwipes = snap?.data() else { return }
            guard let currentUserUID = self.currentUser?.uid else { return }
            let isMatch = swipedUserSwipes[currentUserUID] as? Int == 1
            if isMatch {
                self.presentMatchView(matchedUserUID: swipedUserUID)
                
                //saving match info for both user's firestore collections
                self.saveMatchInfo(matchedUID: swipedUserUID, for: currentUserUID)
                self.saveMatchInfo(matchedUID: currentUserUID, for: swipedUserUID)
            }
        }
    }
    
    fileprivate func saveMatchInfo(matchedUID: String, for userUID: String){
        guard let userInfo = self.fetchedUsersDictionary[matchedUID] else { return }
        let matchData: [String: Any] = [FirestoreKeys.name.rawValue: userInfo.name ?? "",
                                        FirestoreKeys.image1.rawValue: userInfo.imageURL1 ?? "",
                                        FirestoreKeys.uid.rawValue: userInfo.uid,
                                        FirestoreKeys.timestamp.rawValue: Timestamp(date: Date())]
        Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(userUID)
            .collection(FirestoreCollection.matches.rawValue).document(matchedUID).setData(matchData) { error in
                if let error = error {
                    print("Failed to save swipe data, \(error)")
                    self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                    return
                }
        }
    }
    
    fileprivate func presentMatchView(matchedUserUID: String){
        let matchView = MatchView()
        matchView.currentUser = self.currentUser
        matchView.matchedUserUID = matchedUserUID
        matchView.delegate = self
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleProfile() {
        let settingsController = SettingsViewController(style: .grouped)
        settingsController.delegate = self
        let navigationContriller = UINavigationController(rootViewController: settingsController)
        navigationContriller.modalPresentationStyle = .fullScreen
        present(navigationContriller, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleLike() {
        saveSwipe(isLike: true)
        cardSwipe(translationX: 700, digree: 15)
    }
    
    @objc fileprivate func handleDislike() {
        saveSwipe(isLike: false)
        cardSwipe(translationX: -700, digree: -15)
    }
    
    @objc fileprivate func handleRefresh(){
        removeAllCards()
        fetchCurrentUser()
    }
    
    @objc fileprivate func handleChat(){
        guard let currentUser = currentUser else { return }
        let messagingViewController = MessagingController(currentUser: currentUser)
        navigationController?.pushViewController(messagingViewController, animated: true)
    }
    
    //MARK: - Delegation
    func didSaveSettings() {
        handleRefresh()
    }
    
    func didFinishLogin() {
        handleRefresh()
    }
    
    func didLike() {
        saveSwipe(isLike: true)
        cardSwipe(translationX: 700, digree: 15)
    }
    
    func didDislike() {
        saveSwipe(isLike: false)
        cardSwipe(translationX: -700, digree: -15)
    }
    
    func didUserDetailsTapped(cardViewModel: CardViewModel){
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        userDetailsController.delegate = self
        userDetailsController.modalPresentationStyle = .fullScreen
        present(userDetailsController, animated: true)
    }
    
    func didTapSendMessage(currentUser: User, matchedUser: Match) {
        let chatController = ChatController(currentUser: currentUser, match: matchedUser)
        navigationController?.pushViewController(chatController, animated: true)
    }
}

