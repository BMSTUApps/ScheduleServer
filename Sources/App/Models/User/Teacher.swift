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
    
    var scheduleID: Schedule.ID
    
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, department: String, position: String, degree: String, scheduleID: Schedule.ID) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.department = department
        self.position = position
        self.degree = degree
        
        self.scheduleID = scheduleID
    }
}

/// Allows `Teacher` to be used as a migration.
extension Teacher: Migration { }

/// Allows `Teacher` to be encoded to and decoded from HTTP messages.
extension Teacher: Content { }

/// Allows `Teacher` to be used as a dynamic parameter in route definitions.
extension Teacher: Parameter { }
