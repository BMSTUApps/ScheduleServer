import FluentMySQL
import Vapor

/// A teacher.
final class Teacher: MySQLModel {
    
    /// The unique identifier for this teacher.
    var id: Int?
    
    /// The teacher's first name.
    var firstName: String
    
    /// The teacher's last name.
    var lastName: String
    
    /// The teacher's middle name.
    var middleName: String
    
    /// The teacher's photo
    /// ...
    
    /// The department where the teacher works
    /// ...
    
    /// The teacher's position
    var position: String?
    
    /// The teacher's degree
    var degree: String?
    
    /// A link to teacher's schedule
    /// ...
    
    /// Creates a new teacher.
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
    }
}

/// Allows `Teacher` to be used as a migration.
extension Teacher: Migration { }

/// Allows `Teacher` to be encoded to and decoded from HTTP messages.
extension Teacher: Content { }

/// Allows `Teacher` to be used as a dynamic parameter in route definitions.
extension Teacher: Parameter { }
