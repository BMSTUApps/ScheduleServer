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
    
    /// Creates a new user.
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
    }
}

/// Allows `User` to be used as a migration.
extension User: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
