import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Status
    
    router.get("status") { req in
        return "All is ok"
    }

    // User
    
    let userController = UserController()
    try router.register(collection: userController)

    // Schedule
    
    let scheduleController = ScheduleController()
    try router.register(collection: scheduleController)
    
    // Teacher
    
    let teachersController = TeachersController()
    try router.register(collection: teachersController)
}
