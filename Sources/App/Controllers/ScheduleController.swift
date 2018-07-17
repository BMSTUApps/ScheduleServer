import Vapor

/// Controls operations on 'Schedule'.
final class ScheduleController {
    
    /// Returns a list of all 'Schedule'.
    func index(_ req: Request) throws -> Future<[Schedule]> {
        return Schedule.query(on: req).all()
    }
}
