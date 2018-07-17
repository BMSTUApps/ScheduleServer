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
    
    /// The department where the teacher works
    var department: String
    
    /// The teacher's position
    var position: String?
    
    /// The teacher's degree
    var degree: String?
    
    /// Creates a new teacher.
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, department: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.department = department
    }
}

/// Allows `Teacher` to be used as a migration.
extension Teacher: Migration { }

/// Allows `Teacher` to be encoded to and decoded from HTTP messages.
extension Teacher: Content { }

/// Allows `Teacher` to be used as a dynamic parameter in route definitions.
extension Teacher: Parameter { }
