import Vapor

/// Controls operations on 'User'.
final class UsersController {

    /// Returns a list of all 'Users'.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    // TODO: Get user for id
    // TODO: Update user for id
    // TODO: Upload photo for id
}
