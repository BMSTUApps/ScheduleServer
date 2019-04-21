import Foundation
import SwiftSoup

struct RawSchedule {
    let group: RawGroup
    let events: [RawEvent]
}

struct RawGroup {
    let identifier: String
}

struct RawEvent {
    
    enum Kind {
        case lecture
        case seminar
        case lab
        case other
    }
    
    enum Repeat {
        case numerator
        case denominator
        case both
    }
    
    enum Weekday {
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
    
    let kind: Kind
    
    let startTime: String
    let endTime: String
    
    let repeatKind: Repeat
    let weekday: Weekday
    
    let title: String
    let teacher: String
    
    let location: String
    let anotherLocation: String?
}

protocol ScheduleParser {
    func availableGroups(completion: ([RawGroup]) -> ())
    func parseSchedule(for group: RawGroup, completion: (RawSchedule?) -> ())
    func parseSchedules(completion: (RawSchedule?) -> ())
}

class ScheduleRegexParser: ScheduleParser {
    
    private let studentPortalURL = URL(string: "https://students.bmstu.ru")
    
    init() {
        updateGroupsIfNeeded()
    }

    func availableGroups(completion: ([RawGroup]) -> ()) {
            if cachedGroups == nil {
                updateGroupsIfNeeded()
            }
            
            guard let elements = cachedGroups else { return }
            completion(elements.map { $0.raw })
    }
    
    func parseSchedule(for group: RawGroup, completion: (RawSchedule?) -> ()) {
            guard let groupElement = cachedGroups?.first(where: { element -> Bool in
                return element.identificator == group.identifier
            }) else {
                completion(nil)
                return
            }
            
            guard let schedule = getScheduleElement(for: groupElement) else {
                completion(nil)
                return
            }
            
            let events = schedule.events.map { $0.raw }
            completion(RawSchedule(group: group, events: events))
    }
    
    func parseSchedules(completion: (RawSchedule?) -> ()) {
            if cachedGroups == nil {
                updateGroupsIfNeeded()
            }
            
            guard let groups = cachedGroups else {
                return
            }
            
            for group in groups {
                let scheduleElement = getScheduleElement(for: group)
                let events = scheduleElement?.events.map { $0.raw }
                completion(RawSchedule(group: group.raw, events: events ?? []))
            }
            
            return
    }
    
    // MARK: Private
    
    private var cachedGroupsHash: Int?
    private var cachedGroups: [GroupElement]?
    
    private func updateGroupsIfNeeded() {
        queue.sync {
            guard let groupsElements = getGroupsElements() else { return }
            let newHash = generateGroupsElementsHash(groupsElements)
            
            if let oldHash = cachedGroupsHash, oldHash == newHash {
                // No update needed
                return
            }
            
            cachedGroupsHash = newHash
            cachedGroups = groupsElements
        }
    }
    
    private func generateGroupsElementsHash(_ elements: [GroupElement]) -> Int {
        
        var urlsString: String = ""
        elements.forEach { element in
            urlsString.append(element.url.relativeString)
        }
        
        return urlsString.hash
    }
    
    // MARK: Schedules List
    
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
    
    // MARK: Schedule
    
    fileprivate let weekdayStrings = ["понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
    fileprivate let shortWeekdayStrings = ["пн", "вт", "ср", "чт", "пт", "сб"]
    
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
                        
                        // Event
                        let rawEvent = try rowElement.select("td[colspan='2']").text()
                        let event = parseEvent(raw: rawEvent, startTime: time.start, endTime: time.end, repeatKind: .both, weekday: weekday)
                        
                        if event.isValid {
                            events.append(event)
                        }
                        
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
    
    // MARK: Event
    
    private func parseTime(raw: String) -> (start: String, end: String) {
        let elements = raw.split(separator: "-")
        
        let startTime = String(elements[0]).trimmingBoundSpaces()
        let endTime = String(elements[1]).trimmingBoundSpaces()

        return (startTime, endTime)
    }
    
    private func parseEvent(raw: String, startTime: String, endTime: String, repeatKind: EventElement.RepeatKind, weekday: Weekday) -> EventElement {
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
        var anotherLocation: String?
        if let locationRange = raw.range(of: "\\d{3,4}\\w?", options: .regularExpression) {
            location = String(raw[locationRange])
            
            raw.removeSubstring(in: locationRange)
            
            // Check for another location
            if let locationRange = raw.range(of: "\\d{3,4}\\w?", options: .regularExpression) {
                anotherLocation = String(raw[locationRange])
                
                raw.removeSubstring(in: locationRange)
                raw = raw.trimmingBoundCharacter(",")
            }

        } else if let locationRange = raw.lowercased().range(of: "каф") {
            location = "кафедра"
            
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
        
        return EventElement(kind: kind, startTime: startTime, endTime: endTime, repeatKind: repeatKind, weekday: weekday, title: title, teacher: teacher, location: location, anotherLocation: anotherLocation)
    }
}

extension ScheduleRegexParser {
    
    private struct GroupElement {
        
        /// Example: 'ИУ5-51'
        let identificator: String
        let url: URL
        
        var raw: RawGroup {
            return RawGroup(identifier: identificator)
        }
    }
    
    private struct ScheduleElement {
        
        let events: [EventElement]
    }
    
    private struct EventElement {
        
        enum Kind: String {
            case lecture = "лек"
            case seminar = "сем"
            case lab = "лаб"
            case other
            
            var raw: RawEvent.Kind {
                switch self {
                case .lecture:
                    return .lecture
                case .seminar:
                    return .seminar
                case .lab:
                    return .lab
                case .other:
                    return .other
                }
            }
        }
        
        enum RepeatKind: String {
            case numerator = "чс"
            case denominator = "зн"
            case both
            
            var raw: RawEvent.Repeat {
                switch self {
                case .numerator:
                    return .numerator
                case .denominator:
                    return .denominator
                case .both:
                    return .both
                }
            }
        }
        
        let kind: Kind
        
        let startTime: String
        let endTime: String
        
        let repeatKind: RepeatKind
        let weekday: Weekday
        
        let title: String
        let teacher: String

        let location: String
        let anotherLocation: String?

        var isValid: Bool {
            return !title.isEmpty
        }
        
        var raw: RawEvent {
            return RawEvent(kind: kind.raw,
                            startTime: startTime,
                            endTime: endTime,
                            repeatKind: repeatKind.raw,
                            weekday: weekday.raw,
                            title: title,
                            teacher: teacher,
                            location: location,
                            anotherLocation: anotherLocation)
        }
    }
    
    private enum Weekday: String {
        case monday = "пн"
        case tuesday = "вт"
        case wednesday = "ср"
        case thursday = "чт"
        case friday = "пт"
        case saturday = "сб"
        
        var raw: RawEvent.Weekday {
            switch self {
            case .monday:
                return .monday
            case .tuesday:
                return .tuesday
            case .wednesday:
                return .wednesday
            case .thursday:
                return .thursday
            case .friday:
                return .friday
            case .saturday:
                return .saturday
            }
        }
    }
}
