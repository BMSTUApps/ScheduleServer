import FluentMySQL
import Vapor

/// A student's group.
final class Group: MySQLModel {
    
    var id: Int?
    var number: String
    var department: String
    var scheduleID: Schedule.ID
    
    init(id: Int? = nil, number: String, department: String, scheduleID: Schedule.ID) {
        self.id = id
        self.number = number
        self.department = department
        self.scheduleID = scheduleID
    }
}

/// Define coding keys for `Group`.
extension Group {
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case department
        case scheduleID = "schedule_id"
    }
}

/// Allows `Group` to be used as a migration.
extension Group: Migration { }

/// Allows `Group` to be encoded to and decoded from HTTP messages.
extension Group: Content { }

/// Allows `Group` to be used as a dynamic parameter in route definitions.
extension Group: Parameter { }
