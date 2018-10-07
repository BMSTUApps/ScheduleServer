import FluentMySQL
import Vapor

/// An event.
final class Event: MySQLModel {
    
    var id: Int?

    var title: String
    
    var kind: String
    var location: String

    var date: Date
    var repeatIn: Int
    var endDate: Date?
    
    var startTime: String
    var endTime: String

    var teacherID: Teacher.ID?
    var scheduleID: Schedule.ID

    init(id: Int? = nil, title: String, kind: String, location: String, date: Date, repeatIn: Int = 0, endDate: Date? = nil, startTime: String, endTime: String, teacherID: Teacher.ID? = nil, scheduleID: Schedule.ID) {
        self.id = id
        
        self.title = title
        
        self.kind = kind
        self.location = location
        
        self.date = date
        self.repeatIn = repeatIn
        self.endDate = endDate
        
        self.startTime = startTime
        self.endTime = endTime
        
        self.teacherID = teacherID
        self.scheduleID = scheduleID
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        title = try values.decode(String.self, forKey: .title)
        
        kind = try values.decodeIfPresent(String.self, forKey: .kind) ?? "other"
        location = try values.decode(String.self, forKey: .location)
        
        date = try values.decode(Date.self, forKey: .date)
        repeatIn = try values.decode(Int.self, forKey: .repeatIn)
        endDate = try values.decode(Date.self, forKey: .endDate)
        
        startTime = try values.decode(String.self, forKey: .startTime)
        endTime = try values.decode(String.self, forKey: .endTime)
        
        teacherID = try values.decode(Teacher.ID.self, forKey: .teacherID)
        scheduleID = try values.decode(Schedule.ID.self, forKey: .scheduleID)
    }
}

/// Define computed properties for `Event`.
extension Event {
    
    var isRepeat: Bool {
        return repeatIn > 0
    }
}

/// Define coding keys for `Event`.
extension Event {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case kind
        case location
        case date
        case repeatIn = "repeat_in"
        case endDate = "end_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case teacherID = "teacher_id"
        case scheduleID = "schedule_id"
    }
}

/// Allows `Lesson` to be used as a migration.
extension Event: Migration { }

/// Allows `Lesson` to be encoded to and decoded from HTTP messages.
extension Event: Content { }

/// Allows `Lesson` to be used as a dynamic parameter in route definitions.
extension Event: Parameter { }
