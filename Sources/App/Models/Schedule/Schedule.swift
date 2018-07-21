import FluentMySQL
import Vapor

/// A schedule.
final class Schedule: MySQLModel {
    
    /// The unique identifier for this schedule.
    var id: Int?
    
    /// Schedule's lessons
    var lessons: Children<Schedule, Lesson> {
        return children(\.scheduleID)
    }
    
    /// Creates a new schedule.
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
