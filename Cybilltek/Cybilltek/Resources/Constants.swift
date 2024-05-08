//
//  Constants.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import Foundation

class Constants {
    enum StaticLink: String {
        case randomUserURL = "https://randomuser.me/api/?page=1&results=10&seed=abc"
        
        var url: URL? {
            return URL(string: self.rawValue)
        }
    }
}
