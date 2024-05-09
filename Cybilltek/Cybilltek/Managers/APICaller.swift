//
//  APICaller.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/8/24.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let randomUserUrlString = "https://randomuser.me/api/?results=10&seed=abc" // page=1
        static let randomUserURL = URL(string: randomUserUrlString)
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    private init() {}
    var isPaginating = false
    
    public func getUsers(pagination: Bool = false, page: Int, completion: @escaping(Result<[User], Error>) -> Void) {
        let urlString = "\(Constants.randomUserUrlString)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        print("urlString: \(urlString)")
        
        if pagination {
            isPaginating = true
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
                //let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(RandomUserResponse.self, from: data)
                 
                completion(.success(result.results))
                
                if pagination {
                    self.isPaginating = false
                }
            } catch {
                print("getUsers: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            
        }
        task.resume()
    }
}


//let newData = [
//       User(gender: "Male",
//            name: Name(title: "Ms.", first: "Wanda", last: "Maximoff"),
//            location: Location(
//               street: Street(number: 081, name: "Aguinaldo Highway"),
//               city: "St. Vincent - St. Mary",
//               state: "Ohio",
//               country: "USA",
//               postcode: Postcode.integer(4123),
//               coordinates: Coordinates(
//                   latitude: "-80.1242",
//                   longitude: "160.2823"),
//               timezone: Timezone(
//                   offset: "+8:00",
//                   description: "Atlantic Time (Canada), Caracas, La Paz")),
//            email: "jervygu@gmail.com",
//            login: Login(
//               uuid: "2aaabbb2-3e0a-4584-b08b-1ca231ab2145",
//               username: "jervygu",
//               password: "Z5de5nVa",
//               salt: "mememe",
//               md5: "c4ac1714bd3195b127d7f728e40ff523",
//               sha1: "c15556ac00cbc434ec4b2335dfc35ae7e8e17790",
//               sha256: "8f13a50e6908f372ff92b1e24ee88f4fc34f02601e203f41ea8101e71247c08c"),
//            dob: Dob(date: "08-22-1993", age: 30),
//            registered: Dob(date: "08-22-1993", age: 30),
//            phone: "(046) 124 1235",
//            cell: "9077311567",
//            id: ID(name: "UMID", value: "123425123345"),
//            picture: Picture(
//               large: "https://w0.peakpx.com/wallpaper/803/528/HD-wallpaper-wanda-maximoff-avengers-elizabeth-olsen-marvel-new-lokk-scarlett-witch-wandavision.jpg",
//               medium: "https://randomuser.me/api/portraits/med/men/22.jpg",
//               thumbnail: "https://randomuser.me/api/portraits/thumb/men/22.jpg"),
//            nat: "American")
//]
