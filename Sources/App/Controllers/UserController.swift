import Vapor
import Crypto
import FluentMySQL

/// Controls operations on 'User'.
final class UserController {

    /// Returns a list of all users.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
     func login(_ req: Request) throws -> Future<UserTokenResponse> {
        
        // Get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // Create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        
        // Save and return token
        return token.save(on: req).map({ (token) -> UserTokenResponse in
            return UserTokenResponse(token)
        })
    }
    
    /// Creates a new user.
    func signup(_ req: Request) throws -> Future<UserResponse> {
        // Decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            
            // Hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            
            // Save new user
            return User(id: nil, email: user.email, passwordHash: hash, firstName: "", lastName: "", middleName: "", scheduleID: nil).save(on: req)
            
            }.map({ user -> UserResponse in
                return UserResponse(user)
            })
    }
    
    // TODO: Get student for id.
    // TODO: Update student for id.
    // TODO: Upload student's photo for id.
}
