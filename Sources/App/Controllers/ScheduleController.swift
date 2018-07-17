import Vapor

/// Controls operations on 'Schedule'.
final class ScheduleController {
    
    /// Returns a list of all 'Schedule'.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
}
