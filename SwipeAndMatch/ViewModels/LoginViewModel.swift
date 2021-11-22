//
//  LoginViewModel.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-30.
//

import Foundation
import Firebase

final class LoginViewModel {
    var isLogginIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    var email: String? { didSet { checkForm() } }
    var password: String? { didSet { checkForm() } }
    
    fileprivate func checkForm() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLogginIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            completion(error)
        }
    }
}
