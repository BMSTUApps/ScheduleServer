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

extension Student {
    
    var schedule: Parent<Student, Schedule> {
        return parent(\.scheduleID)
    }}

/// Define coding keys for `Student`.
extension Student {
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case photo
        case scheduleID = "schedule_id"
    }
}

/// Allows `Student` to be used as a migration.
extension Student: Migration { }

/// Allows `Student` to be encoded to and decoded from HTTP messages.
extension Student: Content { }

/// Allows `Student` to be used as a dynamic parameter in route definitions.
extension Student: Parameter { }
