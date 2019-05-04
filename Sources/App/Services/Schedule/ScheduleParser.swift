import Foundation

struct RawSchedule {
    let group: RawGroup
    let events: [RawEvent]
}

struct RawGroup {
    let identifier: String
    
    var department: String? {
        let components = identifier.components(separatedBy: "-")
        guard components.count == 2, let department = components.first else {
            return nil
        }
        
        return department
    }
    
    var number: String? {
        let components = identifier.components(separatedBy: "-")
        guard components.count == 2, let number = components.last else {
            return nil
        }
        
        return number
    }
}

struct RawEvent {
    
    enum Kind: String {
        case lecture = "lecture"
        case seminar = "seminar"
        case lab = "lab"
        case other = "other"
    }
    
    enum Repeat {
        case numerator
        case denominator
        case both
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
    
    var teacherFirstNameChar: String? {
        let components = teacher.components(separatedBy: ".")
        return (components.count == 3) ? components[1] : nil
    }
    var teacherMiddleNameChar: String? {
        let components = teacher.components(separatedBy: ".")
        return (components.count == 3) ? components[2] : nil
    }
    var teacherLastName: String? {
        let components = teacher.components(separatedBy: ".")
        return components.first
    }
}

protocol ScheduleParser {
    func availableGroups(completion: ([RawGroup]) -> ())
    func parseSchedule(for group: RawGroup, completion: (RawSchedule?) -> ())
    func parseSchedules(completion: (RawSchedule?) -> ())
}
