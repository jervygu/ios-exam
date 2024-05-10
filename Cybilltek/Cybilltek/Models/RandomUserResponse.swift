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
    let postcode: Postcode
    let coordinates: Coordinates
    let timezone: Timezone
    
    
    func getFullAddress() -> String {
        return "\(self.street.number) \(self.street.name), \(self.city) \(self.state), \(self.country)"
    }
    
    var fullAddress: String {
        return "\(street.number) \(street.name), \(city) \(state), \(country)"
    }
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude, longitude: String
}

enum Postcode: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Postcode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Postcode"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Street
struct Street: Codable {
    let number: Int
    let name: String
}

// MARK: - Timezone
struct Timezone: Codable {
    let offset, description: String
}

// MARK: - Name
struct Name: Codable {
    let title: String
    let first, last: String
    
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
