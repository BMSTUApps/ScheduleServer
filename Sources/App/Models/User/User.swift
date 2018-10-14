import FluentMySQL
import Vapor
import Authentication

/// A user.
final class User: MySQLModel {

    var id: Int?
    
    var firstName: String
    var lastName: String
    var middleName: String

    var email: String
    var passwordHash: String

    var photo: String?
    
    var scheduleID: Schedule.ID?
    
    init(id: Int? = nil, firstName: String, lastName: String, middleName: String, email: String, passwordHash: String, scheduleID: Schedule.ID? = nil) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.email = email
        self.passwordHash = passwordHash
        
        self.scheduleID = scheduleID
    }
    
    var tokens: Children<User, UserToken> {
        return children(\.userID)
    }
    
    var schedule: Parent<User, Schedule>? {
        return parent(\.scheduleID) ?? nil
    }
}

/// Define coding keys for `User`.
extension User {
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case email
        case passwordHash = "password_hash"
        case photo
        case scheduleID = "schedule_id"
    }
}

/// Allows `User` to be used as a migration.
extension User: Migration { }

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

/// Allows `User` to authorized with a password.
extension User: PasswordAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

/// Set token for `User`.
extension User: TokenAuthenticatable {

    typealias TokenType = UserToken
}
