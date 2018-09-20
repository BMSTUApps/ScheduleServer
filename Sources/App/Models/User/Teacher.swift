import FluentMySQL
import Vapor

/// A teacher.
final class Teacher: MySQLModel {
    
    var id: Int?
    
    var firstName: String
    var lastName: String
    var middleName: String
    
    var department: String
    var position: String?
    var degree: String?
    
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, department: String, position: String, degree: String) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.department = department
        self.position = position
        self.degree = degree
    }
}

/// Define coding keys for `Teacher`.
extension Teacher {
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case department
        case position
        case degree
    }
}

/// Allows `Teacher` to be used as a migration.
extension Teacher: Migration { }

/// Allows `Teacher` to be encoded to and decoded from HTTP messages.
extension Teacher: Content { }

/// Allows `Teacher` to be used as a dynamic parameter in route definitions.
extension Teacher: Parameter { }
