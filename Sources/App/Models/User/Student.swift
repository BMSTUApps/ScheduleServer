import FluentMySQL
import Vapor

/// A student.
final class Student: MySQLModel {

    /// The unique identifier for this student.
    var id: Int?

    /// Creates a new student.
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Student` to be used as a migration.
extension Student: Migration { }

/// Allows `Student` to be encoded to and decoded from HTTP messages.
extension Student: Content { }

/// Allows `Student` to be used as a dynamic parameter in route definitions.
extension Student: Parameter { }
