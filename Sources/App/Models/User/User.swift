import FluentMySQL
import Vapor

/// A student.
final class User: MySQLModel {

    var id: Int?
    
    var firstName: String
    var lastName: String
    var middleName: String
    
    var photo: String?

    var scheduleID: Schedule.ID?
    
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, scheduleID: Schedule.ID? = nil) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.scheduleID = scheduleID
    }
}

extension User {
    
    var schedule: Parent<User, Schedule>? {
        return parent(\.scheduleID) ?? nil
    }}

/// Define coding keys for `Student`.
extension User {
    
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
extension User: Migration { }

/// Allows `Student` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Student` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
