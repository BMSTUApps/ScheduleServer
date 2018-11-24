import Vapor
import Crypto
import FluentMySQL

/// Data required to create a user.
struct CreateUserRequest: Content {
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
}
