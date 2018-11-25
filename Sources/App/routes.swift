import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("status") { req in
        return "All is ok"
    }

    // Use user model to create an authentication middleware
//    let token = User.tokenAuthMiddleware()
    
    // User
    
    let usersController = UserController()
    router.get("users", use: usersController.index)
    router.post("signup", use: usersController.signup)
    
    let passwordController = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    passwordController.post("login", use: usersController.login)

    // Schedule
    
    let scheduleController = ScheduleController()
    try router.register(collection: scheduleController)
    
    // Teacher
    
    let teachersController = TeachersController()
    try router.register(collection: teachersController)
}
