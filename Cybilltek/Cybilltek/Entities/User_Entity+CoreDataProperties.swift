//
//  User_Entity+CoreDataProperties.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/10/24.
//
//

import Foundation
import CoreData


extension User_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User_Entity> {
        return NSFetchRequest<User_Entity>(entityName: "User_Entity")
    }

    @NSManaged public var user_dob: String?
    @NSManaged public var user_age: Int64
    
    @NSManaged public var user_email: String?
    @NSManaged public var user_gender: String?
    @NSManaged public var user_location: String?
    
    @NSManaged public var user_title: String?
    @NSManaged public var user_first_name: String?
    @NSManaged public var user_last_name: String?
    
    @NSManaged public var user_phone: String?
    @NSManaged public var user_picture: String?

}

extension User_Entity : Identifiable {

}
