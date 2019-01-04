import Vapor
import Fluent

/// Controls operations on 'Schedule'.
final class ScheduleController: RouteCollection {
    
    func boot(router: Router) throws {
        let scheduleRoute = router.grouped("api", "schedule")
        
        let token = User.tokenAuthMiddleware()
        let tokenController = scheduleRoute.grouped(token)
        
        // REQUEST: api/schedule/
        tokenController.get(use: getSchedule)
        
        // REQUEST: api/schedule/edit
        // TODO: api/schedule/edit
    }
    
    /// Returns a list of all schedules.
    func index(_ req: Request) throws -> Future<[Schedule]> {
        return Schedule.query(on: req).all()
    }
    
    /// Return schedule for user.
    func getSchedule(_ req: Request) throws -> Future<ScheduleResponse> {

        let user = try req.requireAuthenticated(User.self)
        let ownerID = try user.requireID()
        
        // Find user
        let futureUser = User.find(ownerID, on: req).unwrap(or: Abort(.notFound, reason: "User not found."))
        let futureResponse = futureUser.flatMap(to: ScheduleResponse.self) { user in
        
            // Check user's schedule
            guard let schedule = user.schedule else {
                throw Abort(.notFound, reason: "Schedule for user \"\(user.email)\" not found.")
            }
            
            let futureSchedule = schedule.get(on: req)
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
