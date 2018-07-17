import FluentMySQL
import Vapor

/// A student.
final class Student: MySQLModel {

    /// The unique identifier for this student.
    var id: Int?
    
    /// A link to students's user
    var userId: Int?
    
    /// Creates a new student.
    init(id: Int? = nil, userId: Int? = nil) {
        self.id = id
        self.userId = userId
    }
}
