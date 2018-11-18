import Vapor
import Crypto
import FluentMySQL

/// Data required to create a user.
struct CreateUserRequest: Content {
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}
