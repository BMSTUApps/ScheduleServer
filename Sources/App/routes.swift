import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Use user model to create an authentication middleware
    let password = User.basicAuthMiddleware(using: BCryptDigest())
    
    let token = User.tokenAuthMiddleware()
    
    let usersController = UserController()
    router.get("users", use: usersController.index)
    
    let scheduleController = ScheduleController()
    try router.register(collection: scheduleController)
    
    let teachersController = TeachersController()
    try router.register(collection: teachersController)
}
