import Vapor
import Fluent

/// Controls operations on 'Schedule'.
final class ScheduleController: RouteCollection {
    
    func boot(router: Router) throws {
        let scheduleRoute = router.grouped("api", "schedule")
        
        let token = User.tokenAuthMiddleware()
        let tokenController = scheduleRoute.grouped(token) 
    
        // REQUEST: api/schedule/templates
        scheduleRoute.get("templates", use: index)
        
        // REQUEST: api/schedule/
        tokenController.get(use: getSchedule)
        
        // REQUEST: api/schedule/template
        scheduleRoute.get("template", use: getTemplateSchedule)
        
        // REQUEST: api/schedule/edit
        tokenController.post("edit", use: editEvent)
        
        // FIXME: Remove test code
        // REQUEST: api/schedule/parse
        scheduleRoute.get("parse", use: testParse)
    }
    
    /// Returns a list of all template schedules.
    func index(_ req: Request) throws -> Future<[Group]> {
        return Group.query(on: req).all()
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
    
    /// Return schedule for group.
    func getTemplateSchedule(_ req: Request) throws -> Future<ScheduleResponse> {
        
        let groupParam = "group"
        guard let searchGroupIdentificator = req.query[String.self, at: groupParam] else {
            throw Abort.missingParameters([groupParam])
        }
        
        let searchGroupComponents = searchGroupIdentificator.components(separatedBy: "-")
        guard searchGroupComponents.count == 2, let searchGroupDepartment = searchGroupComponents.first, let searchGroupNumber = searchGroupComponents.last else {
            throw Abort.invalidParameters([groupParam])
        }
        
        // Find group
        let futureGroup = Group.query(on: req).filter(\.department == searchGroupDepartment).filter(\.number == searchGroupNumber).first().unwrap(or: Abort(.notFound, reason: "Group not found."))
        let futureResponse = futureGroup.flatMap(to: ScheduleResponse.self) { group in
            
            // Check group's schedule
            guard let schedule = group.schedule else {
                throw Abort(.notFound, reason: "Schedule for group \"\(group.number)\" not found.")
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
                    
                    return ScheduleResponse(id: schedule.id ?? -1, ownerId: group.id ?? -1, isTemplate: schedule.isTemplate, events: responses)
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
    
    // Updates current event
    func editEvent(_ req: Request) throws -> Future<Event> {
        
        let request = try req.content.decode(UpdateEventRequest.self)
        return request.flatMap({ request -> EventLoopFuture<Event> in
            let event = Event.find(request.id, on: req).unwrap(or: Abort(.notFound, reason: "Event not found."))

            return event
        })
    }
    
    func testParse(_ req: Request) -> String {
        
        let service = ScheduleService()
        service.updateSchedules()
                
        return "Parsed"
    }
}
