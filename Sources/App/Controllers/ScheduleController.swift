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
    
    /// Return schedule for user.
    func getSchedule(_ req: Request) throws -> Future<ScheduleResponse> {
        
        guard let ownerID = Int(req.query[String.self, at: ScheduleResponse.CodingKeys.ownerId.stringValue] ?? "Empty") else {
                throw Abort.missingParameters([ScheduleResponse.CodingKeys.ownerId.stringValue])
        }
        
        // Find user
        let futureUser = User.find(ownerID, on: req).unwrap(or: Abort(.notFound, reason: "User not found."))
        let futureResponse = futureUser.flatMap(to: ScheduleResponse.self) { user in
            
            // Find user's schedule
            let futureSchedule = user.schedule!.get(on: req)
            let futureResponse = futureSchedule.flatMap(to: ScheduleResponse.self, { schedule in

                // Get events from schedule
                let repeatEvents = try schedule.events.query(on: req).all()
                let futureResponse = repeatEvents.map(to: ScheduleResponse.self, { events in

                    var responses: [EventResponse] = []
                    
                    for event in events {
                        responses.append(EventResponse(event))
                    }
                    
                    return ScheduleResponse(id: schedule.id ?? -1, ownerId: user.id ?? -1, isTemplate: schedule.isTemplate, events: responses)
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
