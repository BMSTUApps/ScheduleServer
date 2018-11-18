import Vapor
import Crypto
import FluentMySQL

/// Controls operations on 'User'.
final class UserController {

    /// Returns a list of all users.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new user.
    func signup(_ req: Request) throws -> Future<UserResponse> {
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            // verify that passwords match
            guard user.password == user.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            // save new user
            return User(id: nil, email: user.email, passwordHash: hash, firstName: "", lastName: "", middleName: "", scheduleID: nil).save(on: req)
            
            }.map({ user -> UserResponse in
                return try UserResponse(id: user.requireID(), name: user.fullName, email: user.email)
            })
    }
    
    // TODO: Get student for id.
    // TODO: Update student for id.
    // TODO: Upload student's photo for id.
}
