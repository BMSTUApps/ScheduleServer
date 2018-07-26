import FluentMySQL
import Vapor

/// A schedule.
final class Schedule: MySQLModel {
    
    var id: Int?
    
    var lessons: Children<Schedule, Lesson> {
        return children(\.scheduleID)
    }
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Schedule` to be used as a migration.
extension Schedule: Migration { }

/// Allows `Schedule` to be encoded to and decoded from HTTP messages.
extension Schedule: Content { }

/// Allows `Schedule` to be used as a dynamic parameter in route definitions.
extension Schedule: Parameter { }
