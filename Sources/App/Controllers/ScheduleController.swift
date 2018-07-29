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
    func getSchedule(_ req: Request) throws -> Future<ScheduleResponse> {
        
        guard let offset = Int(req.query[String.self, at: ScheduleResponse.CodingKeys.offset.stringValue] ?? "Empty"),
            let count = Int(req.query[String.self, at: ScheduleResponse.CodingKeys.count.stringValue] ?? "Empty"),
            let studentID = Int(req.query[String.self, at: ScheduleResponse.CodingKeys.studentId.stringValue] ?? "Empty") else {
                throw Abort(.badRequest, reason: "Missing parameters in request.")
        }
        
        // Find student
        let futureStudent = Student.find(studentID, on: req).unwrap(or: Abort(.notFound, reason: "Student not found."))
        let futureResponse = futureStudent.flatMap(to: ScheduleResponse.self) { student in
            
            // Find student's schedule
            let futureSchedule = student.schedule.get(on: req)
            let futureResponse = futureSchedule.flatMap(to: ScheduleResponse.self, { schedule in
                
                // Get events from schedule
                let repeatEvents = try schedule.events.query(on: req).filter(\.isRepeat == true).all()
                let futureResponse = repeatEvents.map(to: ScheduleResponse.self, { events in
                    
                    var eventsResponses: [EventResponse] = []
                    
                    for event in events {
                        let eventResponse = EventResponse(id: event.id ?? -1, name: "", kind: event.kind.rawValue, location: event.location, teacher: TeacherShortResponse(id: -1, name: ""), startTime: event.startTime, endTime: event.endTime)
                        
                        eventsResponses.append(eventResponse)
                    }
                    
                    let testDay = DayResponse(date: "12.12.2018", events: eventsResponses)
                    
                    return ScheduleResponse(id: schedule.id ?? -1, offset: offset, count: count, studentId: 0, days: [testDay])
                })
                
                return futureResponse
            })
            
            return futureResponse
        }
        
        return futureResponse
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
