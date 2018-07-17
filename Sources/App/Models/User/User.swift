import FluentMySQL
import Vapor

/// A simple user.
final class User: MySQLModel {
    
    /// The unique identifier for this user.
    var id: Int?
    
    /// The user's first name.
    var firstName: String

    /// The user's last name.
    var lastName: String
    
    /// The user's middle name.
    var middleName: String
    
    /// The user's photo
    var photo: String?
    
    /// A link to user's schedule
    var scheduleID: Int
    
    /// Creates a new user.
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, scheduleID: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.scheduleID = scheduleID
    }
}

/// Allows `User` to be used as a migration.
extension User: Migration { }

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
