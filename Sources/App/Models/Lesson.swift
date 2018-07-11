import FluentMySQL
import Vapor

/// A lesson.
final class Lesson: MySQLModel {
    
    /// The unique identifier for this lesson.
    var id: Int?
    
    /// A link to lesson's subject
    /// ...
    
    /// The lesson's type.
    //var type: LesssonType
    
    /// A link to lesson's teacher
    /// ...
    
    /// The lesson's start time.
    var startTime: String

    /// The lesson's end time.
    var endTime: String

    /// The lesson's location.
    var location: String
    
    /// Creates a new lesson.
    init(id: Int? = nil, startTime: String, endTime: String, location: String) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
    }
}

/// Allows `Lesson` to be used as a migration.
extension Lesson: Migration { }

/// Allows `Lesson` to be encoded to and decoded from HTTP messages.
extension Lesson: Content { }

/// Allows `Lesson` to be used as a dynamic parameter in route definitions.
extension Lesson: Parameter { }
