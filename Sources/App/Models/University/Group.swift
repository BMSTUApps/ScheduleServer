import FluentMySQL
import Vapor

/// A student's group.
final class Group: MySQLModel {
    
    /// The unique identifier for this group.
    var id: Int?
    
    /// The group's number.
    var number: String
    
    /// The group's department.
    var department: String
    
    /// A link to group's schedule
    var scheduleID: Schedule.ID
    
    /// Creates a new group.
    init(id: Int? = nil, number: String, department: String, scheduleID: Schedule.ID) {
        self.id = id
        self.number = number
        self.department = department
        self.scheduleID = scheduleID
    }
}

/// Allows `Group` to be used as a migration.
extension Group: Migration { }

/// Allows `Group` to be encoded to and decoded from HTTP messages.
extension Group: Content { }

/// Allows `Group` to be used as a dynamic parameter in route definitions.
extension Group: Parameter { }
