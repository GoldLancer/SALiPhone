//
//  Extension+Date.swift
//  Market Muscles
//
//  Created by Goldlancer on 2020/2/8.
//  Copyright © 2020 Goldlancer. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        return "\(dateformatter.string(from: self))"
    }
    
    func getChatTimeString() -> String {        
       
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh:mm a"
//        dateformatter.timeZone = TimeZone(abbreviation: "UTC")
        let timeStr = dateformatter.string(from: self)

        let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
        
        if diff == 0 {
            return "\(timeStr)"
        } else if diff == 1 {
            return "Yesterday \(timeStr)"
        }
        
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return "\(dateformatter.string(from: self))"
    }
    
    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    
    func addYear(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .year, value: n, to: self)!
    }
    
    func addDay(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }
    
    func addSec(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        if milliseconds == 0 {
            self = Date()
        } else {
            self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        }
    }
    
    init(dateString: String) {
        let dateFormatter = DateFormatter()
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        print("DateString : \(dateString)")
        let exceptional = dateString.contains("T")
        if exceptional {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        
        self = dateFormatter.date(from: dateString)!
    }
    
    func getDateString(format: String = "MM/dd/YYYY") -> String {

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = format
        
        let dateString = dayTimePeriodFormatter.string(from: self)
        return dateString
    }
}
