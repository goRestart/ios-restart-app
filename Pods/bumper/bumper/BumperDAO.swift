//
//  BumperDAO.swift
//  Pods
//
//  Created by Eli Kohen on 22/09/16.
//
//

import Foundation
import RxSwift
import RxCocoa

protocol BumperDAO {
    func set(_ value: Bool, forKey defaultName: String)
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
    
    func stringObservable(for key: String) -> Observable<String?>
    func boolObservable(for key: String) -> Observable<Bool?>
}

extension UserDefaults: BumperDAO {
    func stringObservable(for key: String) -> Observable<String?> {
        return rx.observe(String.self, key)
    }

    func boolObservable(for key: String) -> Observable<Bool?> {
        return rx.observe(Bool.self, key)
    }
}

