import FluentMySQL
import Vapor

/// A schedule.
final class Schedule: MySQLModel {
    
    var id: Int?
    var isTemplate: Bool
    
    init(id: Int? = nil, isTemplate: Bool) {
        self.id = id
        self.isTemplate = isTemplate
    }
}

/// Define computed properties for `Schedule`.
extension Schedule {
    
    var lessons: Children<Schedule, Event> {
        return children(\.scheduleID)
    }
}

/// Define coding keys for `Schedule`.
extension Schedule {
    
    enum CodingKeys: String, CodingKey {
        case id
        case isTemplate = "is_template"
    }
}

/// Allows `Schedule` to be used as a migration.
extension Schedule: Migration { }

/// Allows `Schedule` to be encoded to and decoded from HTTP messages.
extension Schedule: Content { }

/// Allows `Schedule` to be used as a dynamic parameter in route definitions.
extension Schedule: Parameter { }
