import Vapor

/// Controls operations on 'User'.
final class StudentController {

    /// Returns a list of all 'Student'.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    // TODO: Get student for id.
    // TODO: Update student for id.
    // TODO: Upload student for id.
}
