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
            case lab = "лаб"
            case other
        }
        
        enum RepeatKind: String {
            case numerator = "чс"
            case denominator = "зн"
            case both
        }
        
        let kind: Kind
        
        let startTime: String
        let endTime: String
        
        let repeatKind: RepeatKind
        let weekday: Weekday
        
        let title: String
        let teacher: String
        let location: String
        
        var isValid: Bool {
            return !title.isEmpty
        }
    }
    
    enum Weekday: String {
        case monday = "пн"
        case tuesday = "вт"
        case wednesday = "ср"
        case thursday = "чт"
        case friday = "пт"
        case saturday = "сб"
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
                print("\(group.identificator): \(schedule.events.count) занятий")
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
            print(error)
            
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
            
            let timeElementClass = "bg-grey text-nowrap"
            let numeratorElementClass = "text-success"
            let denominatorElementClass = "text-info"
            
            var events: [EventElement] = []
            for dayElement in filteredDayElements {
                let elements = try dayElement.select("tr").array()
                
                do {
                    // Event weekday
                    guard let weekday = Weekday(rawValue: try elements[0].text().lowercased()),
                        elements.count >= 3 else {
                        continue
                    }
                    
                    let rowElements = elements.suffix(from: 2)
                    for rowElement in rowElements {
                        
                        // Event time
                        let rawTime = try rowElement.select("td[class='\(timeElementClass)']").text()
                        let time = parseTime(raw: rawTime)
                        
                        // Numerator event
                        let rawNumeratorEvent = try rowElement.select("td[class='\(numeratorElementClass)']").text()
                        let numeratorEvent = parseEvent(raw: rawNumeratorEvent, startTime: time.start, endTime: time.end, repeatKind: .numerator, weekday: weekday)
                        
                        if numeratorEvent.isValid {
                            events.append(numeratorEvent)
                        }

                        // Denominator event
                        let rawDenominatorEvent = try rowElement.select("td[class='\(denominatorElementClass)']").text()
                        let denominatorEvent = parseEvent(raw: rawDenominatorEvent, startTime: time.start, endTime: time.end, repeatKind: .denominator, weekday: weekday)
                        
                        if denominatorEvent.isValid {
                            events.append(denominatorEvent)
                        }
                    }
                    
                } catch let error {
                    
                    // TODO: Handle error
                    print(error)
                }
            }
            
            return ScheduleElement(events: events)
            
        } catch let error {
            
            // TODO: Handle error
            print(error)
            
            return nil
        }
    }
    
    func parseTime(raw: String) -> (start: String, end: String) {
        let elements = raw.split(separator: "-")
        
        let startTime = String(elements[0]).trimmingBoundSpaces()
        let endTime = String(elements[1]).trimmingBoundSpaces()

        return (startTime, endTime)
    }
    
    func parseEvent(raw: String, startTime: String, endTime: String, repeatKind: EventElement.RepeatKind, weekday: Weekday) -> EventElement {
        var raw = raw.replacingOccurrences(of: "\u{00A0}", with: " ")
        
        // Parse kind
        var kind: EventElement.Kind = .other
        if let kindRange = raw.range(of: "\\(\\w{3}\\)", options: .regularExpression) {
            
            let rawKindValue = String(raw[kindRange]).removingSubstrings(["(", ")"])
            if let kindValue = EventElement.Kind(rawValue: rawKindValue) {
                kind = kindValue
            }
            
            raw.removeSubstring(in: kindRange)
        }
        
        // Parse location
        var location = ""
        if let locationRange = raw.range(of: "\\d{3,4}\\w?", options: .regularExpression) {
            location = String(raw[locationRange])
            
            raw.removeSubstring(in: locationRange)
        }
        
        // Parse teacher
        var teacher = ""
        if let teacherRange = raw.range(of: "\\w{3,15}\\s\\w\\.\\s\\w\\.", options: .regularExpression) {
            teacher = String(raw[teacherRange])
            
            raw.removeSubstring(in: teacherRange)
        }
        
        // Parse title
        let title = raw.trimmingBoundSpaces()
        
        return EventElement(kind: kind, startTime: startTime, endTime: endTime, repeatKind: repeatKind, weekday: weekday, title: title, teacher: teacher, location: location)
    }
}

