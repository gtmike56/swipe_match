//
//  RegistrationViewModel.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-26.
//

import UIKit
import Firebase

final class RegistrationViewModel {
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()

    var name: String? { didSet { checkForm() } }
    var email: String? { didSet { checkForm() } }
    var password: String? { didSet { checkForm() } }
    
    func checkForm() {
        let isFormValid = self.name?.isEmpty == false && self.email?.isEmpty == false && self.password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    //Step 1 - creating record of the user in the database
    func performRegistration(completion: @escaping ((Error?) -> ())) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { response, error in
            if let error = error {
                completion(error)
                return
            }
            self.saveImageToFirebase(completion: completion)
        }
    }
    //Step 2 - saving user's image into database and keeping the url of the image
    fileprivate func saveImageToFirebase(completion: @escaping ((Error?)->())) {
        let filename = UUID().uuidString
        let storageReference = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.8) ?? Data()
        storageReference.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(error)
                return
            }
            storageReference.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                let imageURL = url?.absoluteString ?? ""
                self.saveUserInfo(imageURL: imageURL, completion: completion)
            }
        }
    }
    //Step 3 - saving default user's data into database
    fileprivate func saveUserInfo(imageURL: String, completion: @escaping ((Error?)->())) {
        guard let uid = Auth.auth().currentUser?.uid, let name = name else { return }
        let usersInfo: [String: Any] = [FirestoreKeys.uid.rawValue: uid,
                                        FirestoreKeys.name.rawValue: name,
                                        FirestoreKeys.age.rawValue: Helper.minAge,
                                        FirestoreKeys.image1.rawValue: imageURL,
                                        FirestoreKeys.minSeekAge.rawValue: Helper.minAge,
                                        FirestoreKeys.maxSeekAge.rawValue: Helper.maxAge]
        Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(uid).setData(usersInfo) { error in
            if let error = error {
                completion(error)
                return
            }
            self.bindableIsRegistering.value = false
            completion(nil)
        }
    }
}
