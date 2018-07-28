import Vapor
import Fluent

/// Controls operations on 'Schedule'.
final class ScheduleController: RouteCollection {
    
    func boot(router: Router) throws {
        let teachersRoute = router.grouped("api", "schedule")
        
        teachersRoute.get(use: getSchedule)
    }
    
    /// Returns a list of all schedules.
    func index(_ req: Request) throws -> Future<[Schedule]> {
        return Schedule.query(on: req).all()
    }
    
    /// Return schedule for student.
    func getSchedule(_ req: Request) throws -> Future<Schedule> {
        
        guard let studentID = Int(req.query[String.self, at: Student.CodingKeys.id.stringValue] ?? "Empty") else {
            throw Abort(.badRequest, reason: "Missing student id in request.")
        }
        
        let futureStudent = Student.find(studentID, on: req).unwrap(or: Abort(.notFound, reason: "Student not found."))
        
        return futureStudent.flatMap(to: Schedule.self, { student in
            return student.schedule.get(on: req)
        })
    }
    
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
