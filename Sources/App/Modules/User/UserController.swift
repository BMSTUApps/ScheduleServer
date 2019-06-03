import Vapor
import Crypto
import FluentMySQL

/// Controls operations on 'User'.
final class UserController: RouteCollection {

    func boot(router: Router) throws {
        let userRoute = router.grouped("api", "user")
        
        let simpleAuth = User.basicAuthMiddleware(using: BCryptDigest())
        let authController = userRoute.grouped(simpleAuth)
        
        // REQUEST: api/user/sign_up
        userRoute.post("sign_up", use: signUp)
        
        // REQUEST: api/user/login
        authController.post("login", use: login)
        
        // REQUEST: api/user/update
//        authController.post("update", use: update)
    }
    
    /// Create a new token for user
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
    
    /// Create a new user
    func signUp(_ req: Request) throws -> EventLoopFuture<EventLoopFuture<EventLoopFuture<UserResponse>>> {
        
        // Decode request content
        let request = try req.content.decode(SignUpRequest.self)
        
        // Get schedule template ID
        let templateID = request.map(to: Int.self) { (createUserRequest) -> Int in
            return createUserRequest.templateScheduleID
        }
        
        // Get template schedule
        let templateSchedule = templateID.flatMap(to: Schedule.self) { (scheduleTemplateID) -> EventLoopFuture<Schedule> in
            return Schedule.find(scheduleTemplateID, on: req).unwrap(or: Abort(.notFound, reason: "Template schedule not found."))
        }
        
        // Create schedule from template and usert
        let future = templateSchedule.map { template -> EventLoopFuture<EventLoopFuture<UserResponse>> in
            let schedule = Schedule(id: nil, isTemplate: false)
    
            // Save schedule
            let future = schedule.create(on: req).map({ schedule -> EventLoopFuture<(User, [EventLoopFuture<Event>])> in
                let scheduleID = try schedule.requireID()

                // Copy events from templates
                let futureEvents = try template.events.query(on: req).all().map({ events -> [EventLoopFuture<Event>] in
                    
                    var futures: [EventLoopFuture<Event>] = []
                    for event in events {
                        
                        let newEvent = Event(id: nil, title: event.title, kind: event.kind, location: event.location, date: event.date, repeatIn: event.repeatIn, endDate: event.endDate, startTime: event.startTime, endTime: event.endTime, teacherID: event.teacherID, scheduleID: scheduleID)
                        
                        futures.append(newEvent.create(on: req))
                    }
                    
                    return futures
                })
                
                // Create new user
                let futureUser = request.flatMap { user -> Future<User> in
                    
                    // Hash user's password using BCrypt
                    let hash = try BCrypt.hash(user.password)
                    
                    // Save new user
                    let newUser = User(user, passwordHash: hash)
                    newUser.scheduleID = scheduleID
                    newUser.templateScheduleID = try template.requireID()
                    
                    return newUser.create(on: req)
                }
                
                return futureUser.and(futureEvents)
            })

            return future.map({ future -> EventLoopFuture<UserResponse> in
                return future.map({ (user, _) -> UserResponse in
                    return UserResponse(user)
                })
            })
        }
        
        return future
    }
    
    /// Update user
//    func update(_ req: Request) throws -> Future<UserResponse> {
//
//        // Get user auth'd by basic auth middleware
//        let user = try req.requireAuthenticated(User.self)
//
//        // Update user
//    }
}
