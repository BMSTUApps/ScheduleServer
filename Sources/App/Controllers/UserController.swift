import Vapor
import Crypto
import FluentMySQL

/// Controls operations on 'User'.
final class UserController {

    /// Returns a list of all users.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
     func login(_ req: Request) throws -> Future<UserTokenResponse> {
        
        // Get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // Create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        
        // Save and return token
        return token.save(on: req).map({ (token) -> UserTokenResponse in
            return UserTokenResponse(token)
        })
    }
    
    /// Creates a new user.
    func signup(_ req: Request) throws -> Future<UserResponse> {
        
        // Decode request content
        let request = try req.content.decode(CreateUserRequest.self)
        
        // Get schedule template ID
        let templateID = request.map(to: Int.self) { (createUserRequest) -> Int in
            return createUserRequest.templateScheduleID
        }
        
        // Get template schedule
        let templateSchedule = templateID.flatMap(to: Schedule.self) { (scheduleTemplateID) -> EventLoopFuture<Schedule> in
            return Schedule.find(scheduleTemplateID, on: req).unwrap(or: Abort(.notFound, reason: "Schedule not found."))
        }
        
        // Create schedule from template
        templateSchedule.flatMap { (template) -> EventLoopFuture<Schedule> in
            
            let schedule = Schedule(id: nil, isTemplate: false)
            let scheduleID = try schedule.requireID()
            
            try template.events.query(on: req).all().map(to: Int.self, { (events) -> Int in
                
                for event in events {
                    
                    let newEvent = Event(id: nil, title: event.title, kind: event.kind, location: event.location, date: event.date, repeatIn: event.repeatIn, endDate: event.endDate, startTime: event.startTime, endTime: event.endTime, teacherID: event.teacherID, scheduleID: scheduleID)
                    
                    newEvent.save(on: req)
                }
                
                return 0
            })
            
            return schedule.save(on: req)
        }
        
        return request.flatMap { user -> Future<User> in
            
            // Hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            
            // Save new user
            return User(user, passwordHash: hash).save(on: req)
            
        }.map({ user -> UserResponse in
            return UserResponse(user)
        })
    }
    
    // TODO: Get student for id.
    // TODO: Update student for id.
    // TODO: Upload student's photo for id.
}
