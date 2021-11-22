//
//  MessagingViewController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-15.
//

import UIKit
import Firebase

final class MessagingController: CustomCollectionViewController<RecentMessageCell, RecentMessage, MatchesHeader, UICollectionReusableView>, MatchesHorizontalControllerDelegate {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        customNavigationBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        fetchLastMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            //removing firebase listner when leaving the controller
            listner?.remove()
        }
    }
    
    //MARK: - Initialization
    fileprivate let customNavigationBar = MessagesNavBar()
    fileprivate let currentUser: User
    var recentMessages = [String: RecentMessage]()

    init(currentUser: User) {
        self.currentUser = currentUser
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate let navBarHeight: CGFloat = 75
    fileprivate func layoutSetup(){
        view.addSubview(customNavigationBar)
        customNavigationBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.scrollIndicatorInsets.top = navBarHeight
        
        let navBarCover = UIView()
        navBarCover.backgroundColor = .white
        view.addSubview(navBarCover)
        navBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    override func setupHeader(header: MatchesHeader) {
        header.matchesHorizontalController.delegate = self
    }
    
    //MARK: - Fileprivates
    fileprivate var listner: ListenerRegistration?
    fileprivate func fetchLastMessages(){
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        listner = Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(currentUserUid).collection(FirestoreCollection.recent_messages.rawValue).addSnapshotListener { snapListner, error in
            if let error = error {
                print("Failed to add listner for recent messages, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            snapListner?.documentChanges.forEach({ change in
                if change.type == .added || change.type == .modified{
                    let recentMessageData = change.document.data()
                    let recentMessage = RecentMessage.init(messageData: recentMessageData)
                    self.recentMessages[recentMessage.uid] = recentMessage
                }
            })
            self.resetItems()
        }
    }
    
    fileprivate func resetItems() {
        let values = Array(recentMessages.values)
        items = values.sorted(by: {(message1, message2) -> Bool in
            return message1.timestamp.compare(message2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleBack(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Delegation
    func didTappedOnMatch(match: Match) {
        let chatController = ChatController(currentUser: currentUser, match: match)
        navigationController?.pushViewController(chatController, animated: true)
    }
}
//MARK: - CollectionView setup
extension MessagingController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = items[indexPath.item]
        let matchData: [String: Any] = [FirestoreKeys.name.rawValue: recentMessage.name,
                                        FirestoreKeys.uid.rawValue: recentMessage.uid,
                                        FirestoreKeys.image1.rawValue: recentMessage.userImageUrl]
        let match = Match.init(matchData: matchData)
        let chatController = ChatController(currentUser: currentUser, match: match)
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
}
