import FluentMySQL
import Vapor
import Authentication

/// A student.
final class User: MySQLModel {

    var id: Int?
    
    var email: String
    var passwordHash: String
    
    var firstName: String
    var lastName: String
    var middleName: String
    
    var photo: String?

    var scheduleID: Schedule.ID?
    
    init(id: Int? = nil, email: String = "", passwordHash: String = "", firstName: String, lastName: String, middleName: String?, scheduleID: Schedule.ID? = nil) {
        self.id = id
        
        self.email = email
        self.passwordHash = passwordHash
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName ?? ""
        
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
        case email
        case passwordHash = "password_hash"
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

extension User: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}
