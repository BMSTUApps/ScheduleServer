import Vapor

/// Controls operations on 'Users'.
final class UsersController {

    /// Returns a list of all 'Users'.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
}
