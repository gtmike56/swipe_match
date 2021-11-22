//
//  MatchesHorizontalController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-11-19.
//

import UIKit
import Firebase

protocol MatchesHorizontalControllerDelegate: AnyObject {
    func didTappedOnMatch(match: Match)
}

final class MatchesHorizontalController: CustomCollectionViewController<MatchCell, Match, MatchesHeader, UICollectionReusableView> {
    weak var delegate: MatchesHorizontalControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        fetchMatches()
    }
    
    //MARK: - Fileprivates
    fileprivate func fetchMatches() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(FirestoreCollection.matches_messages.rawValue).document(currentUserUID).collection(FirestoreCollection.matches.rawValue).getDocuments { snapListner, error in
            if let error = error {
                print("Failed to fetch matches, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                return
            }
            var matches = [Match]()
            snapListner?.documents.forEach({ snap in
                let matchData = snap.data()
                matches.append(.init(matchData: matchData))
            })
            self.items = matches
            self.collectionView.reloadData()
        }
    }
}
//MARK: - CollectionView setup
extension MatchesHorizontalController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let match = items[indexPath.item]
        delegate?.didTappedOnMatch(match: match)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }

}
