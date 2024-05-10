//
//  Constants.swift
//  Cybilltek
//
//  Created by Jervy Umandap on 5/10/24.
//

import Foundation


class Constants {
    enum APIError: Error {
        case failedToGetData
    }
    
    enum StaticLink: String {
        case randomUser = "https://randomuser.me/api/?results=10&seed=abc" // page=1
        
        var url: URL? {
            return URL(string: self.rawValue)
        }
    }
    
    struct DateFormat {
        static let defaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let default12hrDateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
        static let approvalDetailPostedDate = "MMMM dd, yyyy, hh:mm a"
        static let approvalDetailActivityDate = "MMMM dd, yyyy, hh:mm a"
        static let approvalDetailActivitySectionTitle = "MMMM dd, yyyy, EEEE"
        static let approvalDetailActivityDetail = "hh:mm a"
        static let standardDateTime = "MMMM dd, yyyy, hh:mm a"
        static let standardDateTimeSplit = "MMMM dd, yyyy\nhh:mm a"
        static let standardDate = "MMMM dd, yyyy"
        static let loginDateTime = "MMM. dd, yyyy HH:mm:ss a"
        static let yearMonthDay = "yyyy-MM-dd"
        static let monthDayYear = "MM/dd/yyyy"
        static let yearMonthDayZ = "yyyy-MM-ddZ"
        static let gmt8 = " (GMT+8:00)"
        static let MDYE = "MMMM dd, yyyy, EEEE" //Month, Day, Year, DayOfTheWeek
        static let monthDayYearTimeWMeridiem = "M/d/yy, h:mm a"
    }
    
    static func formatDate(date: String, baseFormat: String, outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = baseFormat
        
        let date = dateFormatter.date(from: date) ?? Date()
        dateFormatter.dateFormat = outputFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "PHT")
        
        return dateFormatter.string(from: date)
    }
}
