import Vapor
import SwiftSoup

class ScheduleParser {
    
    static let shared = ScheduleParser()
    
    private let studentPortalURL = URL(string: "https://students.bmstu.ru")
    
    struct GroupElement {
        
        /// Example: 'ИУ5-51'
        let identificator: String
        let url: URL
    }
    
    struct ScheduleElement {
        
        let events: [EventElement]
    }
    
    struct EventElement {
        
        enum Kind: String {
            case lecture = "лек"
            case seminar = "сем"
            case other
        }
        
        enum RepeatKind: String {
            case numerator = "чс"
            case denominator = "зн"
            case both
        }
        
        let kind: Kind
        let repeatKind: RepeatKind
        let title: String
        let teacher: String
        let location: String
    }
    
    fileprivate let weekdayStrings = ["понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
    fileprivate let shortWeekdayStrings = ["пн", "вт", "ср", "чт", "пт", "сб"]

    func parse() {
        
        guard let groupsList = self.getGroupsElements() else {
            return
        }
        
        var schedules: [ScheduleElement] = []
        for group in groupsList {
            
            if let schedule = self.getScheduleElement(for: group) {
                schedules.append(schedule)
            }
        }
    
        // ..
    }
    
    private func getGroupsElements() -> [GroupElement]? {
        
        guard let url = studentPortalURL?.appendingPathComponent("schedule").appendingPathComponent("list") else {
            return nil
        }
        
        do {
            
            let html = try String.init(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            
            let groupElementClass = "btn btn-sm btn-default text-nowrap"
            let rawGroupElements = try document.select("a[class='\(groupElementClass)']")

            let groupElements = try rawGroupElements.compactMap { rawElement -> GroupElement? in
                
                let path = try rawElement.attr("href")
                var identificator = try rawElement.text()

                // Remove unnecessary data
                // Example: 'ИУ5-51Б (Б)' -> 'ИУ5-51Б'
                identificator = identificator.components(separatedBy: " ").first ?? identificator
                
                if let url = studentPortalURL?.appendingPathComponent(path) {
                    return GroupElement(identificator: identificator, url: url)
                } else {
                    return nil
                }
            }
            
            return groupElements
        
        } catch let error {

            // TODO: Handle error
            
            return nil
        }
    }
    
    private func getScheduleElement(for group: GroupElement) -> ScheduleElement? {
        
        do {
            
            let html = try String.init(contentsOf: group.url)
            let document = try SwiftSoup.parse(html)
            
            let dayElementClass = "table table-bordered text-center table-responsive"
            let rawDayElements = try document.select("table[class='\(dayElementClass)']")
            
            // Remove duplicate days
            let filteredDayElements = try rawDayElements.filter { element -> Bool in
                let dayTitle = try element.select("strong").text().lowercased()
                
                return shortWeekdayStrings.contains(dayTitle)
            }
            
            for dayElement in filteredDayElements {
                
                // TODO: Get events from day
                // ...
            }
            
            return ScheduleElement(events: [])
            
        } catch let error {
            
            // TODO: Handle error

            return nil
        }
    }
    
}

