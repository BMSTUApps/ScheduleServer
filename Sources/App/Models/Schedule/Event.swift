import FluentMySQL
import Vapor

/// An event.
final class Event: MySQLModel {
    
    enum Kind: String, Codable {
        case lecture
        case seminar
        case lab
        case other = ""
    }
    
    var id: Int?
    
    var kind: Kind
    var location: String

    var date: Date?
    var repeatIn: String?
    
    var startTime: String
    var endTime: String
    
    var subjectID: Subject.ID
    var scheduleID: Schedule.ID
    var teacherID: Teacher.ID?
    
    init(id: Int? = nil, kind: Kind, location: String, date: Date? = nil, repeatIn: String, startTime: String, endTime: String, subjectID: Subject.ID, teacherID: Teacher.ID? = nil, scheduleID: Schedule.ID) {
        self.id = id
        
        self.kind = kind
        self.location = location
        
        self.date = date
        self.repeatIn = repeatIn
        
        self.startTime = startTime
        self.endTime = endTime
        
        self.subjectID = subjectID
        self.scheduleID = scheduleID
        self.teacherID = teacherID
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        kind = try values.decodeIfPresent(Event.Kind.self, forKey: .kind) ?? .other
        location = try values.decode(String.self, forKey: .location)
        
        date = try values.decode(Date.self, forKey: .date)
        repeatIn = try values.decode(String.self, forKey: .repeatIn)
        
        startTime = try values.decode(String.self, forKey: .startTime)
        endTime = try values.decode(String.self, forKey: .endTime)
        
        subjectID = try values.decode(Subject.ID.self, forKey: .subjectID)
        scheduleID = try values.decode(Schedule.ID.self, forKey: .scheduleID)
        teacherID = try values.decode(Teacher.ID.self, forKey: .teacherID)
    }
}

/// Define computed properties for `Event`.
extension Event {
    
    var isRepeat: Bool {
        return (date == nil) && (repeatIn != nil)
    }
}

/// Define coding keys for `Event`.
extension Event {
    
    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case location
        case date
        case repeatIn = "repeat"
        case startTime = "start_time"
        case endTime = "end_time"
        case subjectID = "subject_id"
        case scheduleID = "schedule_id"
        case teacherID = "teacher_id"
    }
}

/// Allows `Lesson` to be used as a migration.
extension Event: Migration { }

/// Allows `Lesson` to be encoded to and decoded from HTTP messages.
extension Event: Content { }

/// Allows `Lesson` to be used as a dynamic parameter in route definitions.
extension Event: Parameter { }
