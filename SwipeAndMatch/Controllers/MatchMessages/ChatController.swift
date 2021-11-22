//
//  ChatController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-16.
//

import UIKit
import Firebase

final class ChatController: CustomCollectionViewController<MessageCell, Message, UICollectionReusableView, UICollectionReusableView> {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheLastMessage), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        layoutSetup()
        fetchMessages()
    }
    
    //removing firebase listner when leaving the controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listner?.remove()
        }
    }
    
    //MARK: - Initialization
    fileprivate let match: Match
    fileprivate let currentUser: User
    init(currentUser: User, match: Match) {
        self.match = match
        self.currentUser = currentUser
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout setup
    fileprivate lazy var customNavigationBar = ChatNavBar(match: match)
    fileprivate let navBarHeight: CGFloat = 80
    fileprivate func layoutSetup() {
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(customNavigationBar)
        customNavigationBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        customNavigationBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        collectionView.contentInset.top = navBarHeight
        
        if #available(iOS 13.0, *) {
            collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        } else {
            collectionView.scrollIndicatorInsets.top = navBarHeight
        }
        
        let navBarCover = UIView()
        navBarCover.backgroundColor = .white
        view.addSubview(navBarCover)
        navBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    //input accessory view
    fileprivate lazy var accessoryView: CustomInputAccessoryView = {
        let accessoryView = CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 60))
        accessoryView.sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return accessoryView
    }()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return accessoryView
        }
    }
    //MARK: - Fileprivates
    fileprivate var listner: ListenerRegistration?
    fileprivate func fetchMessages() {
        //listner for new sent messages
        let query = Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(currentUser.uid).collection(match.uid).order(by: FirestoreCollection.timestamp.rawValue)
        listner = query.addSnapshotListener { snap, error in
            if let error = error {
                print("Failed to add listner for new sent messages, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            snap?.documentChanges.forEach({ change in
                if change.type == .added {
                    let newMessageData = change.document.data()
                    let newMessage = Message.init(messageData: newMessageData)
                    self.items.append(newMessage)
                }
                self.collectionView.reloadData()
                self.scrollToTheLastMessage()
            })
        }
    }
    
    @objc fileprivate func handleSendMessage(){
        let messageText = accessoryView.textView.text ?? ""
        let messageData: [String: Any] = [FirestoreKeys.messageText.rawValue: messageText,
                                          FirestoreKeys.fromUID.rawValue: currentUser.uid,
                                          FirestoreKeys.toUID.rawValue: match.uid,
                                          FirestoreKeys.timestamp.rawValue: Timestamp(date: Date())]
        
        //saving sent message and recent message for both user's firestore collections
        saveMessage(userUID1: currentUser.uid, userUID2: match.uid, messageData: messageData)
        saveMessage(userUID1: match.uid, userUID2: currentUser.uid, messageData: messageData)
        
        sendRecentMessage(recentMessage: messageText)
    }
    
    fileprivate func saveMessage(userUID1: String, userUID2: String, messageData: [String: Any]) {
        Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(userUID1).collection(userUID2).addDocument(data: messageData) { error in
            if let error = error {
                print("Failed to save message, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            self.accessoryView.textView.text = ""
            self.accessoryView.resetAccessoryView()
            self.scrollToTheLastMessage()
        }
    }
    
    fileprivate func sendRecentMessage(recentMessage: String) {
        //ssaving recent message for current user
        let recentMessageDataForCurrentUser: [String: Any] = [FirestoreKeys.uid.rawValue: match.uid,
                                                              FirestoreKeys.name.rawValue: match.name,
                                                              FirestoreKeys.lastMessage.rawValue: recentMessage,
                                                              FirestoreKeys.image1.rawValue: match.imageURL1,
                                                              FirestoreKeys.timestamp.rawValue: Timestamp(date: Date())]
        
        Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(currentUser.uid).collection(FirestoreCollection.recent_messages.rawValue).document(match.uid).setData(recentMessageDataForCurrentUser) { error in
            if let error = error {
                print("Failed to save recent message, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
        }
        
        //ssaving recent message for matched user
        let recentMessageDataForMatchedUser: [String: Any] = [FirestoreKeys.uid.rawValue: currentUser.uid,
                                                              FirestoreKeys.name.rawValue: currentUser.name ?? "",
                                                              FirestoreKeys.lastMessage.rawValue: recentMessage,
                                                              FirestoreKeys.image1.rawValue: currentUser.imageURL1 ?? "",
                                                              FirestoreKeys.timestamp.rawValue: Timestamp(date: Date())]
        
        Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(match.uid).collection(FirestoreCollection.recent_messages.rawValue).document(currentUser.uid).setData(recentMessageDataForMatchedUser) { error in
            if let error = error {
                print("Failed to save recent message, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
        }
        
    }
    
    //MARK: - Selectors
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func scrollToTheLastMessage(){
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
}
//MARK: - CollectionView setup
extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = estimatedCellHeight(for: indexPath, cellWidth: width)
        return .init(width: width, height: height)
    }
}
