//
//  Date+Utils.swift
//  App
//
//  Created by Artem Belkov on 07/10/2018.
//

import Foundation

fileprivate let defaultCalendar = ServerDateService.calendar
fileprivate let defaultFormat = ServerDateService.dateFormat

enum Weekday: Int {
    case monday = 3
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

extension Date {
    
    static var now: Date {
        return Date()
    }
    
    static func date(of weekday: Weekday, weekNumber: Int) -> Date {
        let dateComponents = DateComponents(weekday: weekday.rawValue, weekOfYear: weekNumber, yearForWeekOfYear: now.year)
        return defaultCalendar.date(from: dateComponents)!
    }
    
    init?(_ string: String, format: String = defaultFormat) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    var week: Int {
        return defaultCalendar.component(.weekOfYear, from: self)
    }
    
    var year: Int {
        return defaultCalendar.component(.year, from: self)
    }
    
    func string(_ format: String = defaultFormat) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
