//
//  UserTableViewCellViewModel.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import Foundation
import RxSwift
import RxCocoa


struct UserTableViewCellViewModel {
    let imageURL: URL?
    let name: String
    let country: String
    let email: String
    let phone: String
}


class UserViewModel {
    var users = BehaviorSubject(value: [User]())
    
    func fetchUsers() {
        let url = Constants.StaticLink.randomUserURL.url!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(RandomUserResponse.self, from: data)
                self.users.on(.next(results.results))
            } catch {
                print("fetchUsers: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
