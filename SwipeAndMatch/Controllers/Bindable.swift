//
//  Binable.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-27.
//

import Foundation

final class Bindable<T> {
    var value: T? { didSet { observer?(value) } }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?)->()) {
        self.observer = observer
    }
}
