import Vapor

/// Controls operations on 'Schedule'.
final class ScheduleController {
    
    /// Returns a list of all schedules.
    func index(_ req: Request) throws -> Future<[Schedule]> {
        return Schedule.query(on: req).all()
    }
    
    // TODO: Get schedule for user
    
    /// Creates schedule for user.
    func createSchedule(_ req: Request) throws -> Future<Schedule> {
        
        return try req.content.decode(Schedule.self).flatMap({ schedule in
            return schedule.save(on: req)
        })
    }
    
    /// Updates schedule for user.
    func updateSchedule(_ req: Request) throws -> Future<Schedule> {
        
        return try req.content.decode(Schedule.self).flatMap({ schedule in
            return schedule.update(on: req)
        })
    }
}
