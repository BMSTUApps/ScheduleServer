import FluentMySQL
import Vapor

/// A student.
final class Student: MySQLModel {

    var id: Int?
    
    var firstName: String
    var lastName: String
    var middleName: String
    
    var photo: String?

    var scheduleID: Schedule.ID
    
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, scheduleID: Schedule.ID) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.scheduleID = scheduleID
    }
}

/// Allows `Student` to be used as a migration.
extension Student: Migration { }

/// Allows `Student` to be encoded to and decoded from HTTP messages.
extension Student: Content { }

/// Allows `Student` to be used as a dynamic parameter in route definitions.
extension Student: Parameter { }
