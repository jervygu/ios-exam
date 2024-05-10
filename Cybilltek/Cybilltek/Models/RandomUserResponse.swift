//
//  RandomUserResponse.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import Foundation


// MARK: - RandomUserResponse
struct RandomUserResponse: Codable {
    let results: [User]
    let info: Info
}

// MARK: - Info
struct Info: Codable {
    let seed: String
    let results, page: Int
    let version: String
}

// MARK: - Result
struct User: Codable {
    let id: ID
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let dob: Dob
    let phone: String
    let picture: Picture
    let nat: String
}

// MARK: - Dob
struct Dob: Codable {
    let date: String
    let age: Int
    
    var formattedDate: String {
        let newDate = Constants.formatDate(date: date, baseFormat: Constants.DateFormat.defaultDateFormat, outputFormat: Constants.DateFormat.standardDate)
        return newDate
    }
}

// MARK: - ID
struct ID: Codable {
    let name: String
    let value: String?
}

// MARK: - Location
struct Location: Codable {
    let street: Street
    let city, state, country: String
    
    
    func getFullAddress() -> String {
        return "\(self.street.number) \(self.street.name), \(self.city) \(self.state), \(self.country)"
    }
    
    var fullAddress: String {
        return "\(street.number) \(street.name), \(city) \(state), \(country)"
    }
}

// MARK: - Street
struct Street: Codable {
    let number: Int
    let name: String
}

// MARK: - Name
struct Name: Codable {
    let title, first, last: String
    
    var fullName: String {
        return "\(first) \(last)"
    }
    
    var titleFullName: String {
        if title.lowercased() == "mr" || title.lowercased() == "mrs" || title.lowercased() == "ms" {
            return "\(title). \(first) \(last)"
        }
        return "\(title) \(first) \(last)"
    }
}

// MARK: - Picture
struct Picture: Codable {
    let large: String
}
