import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("status") { req in
        return
            """
            Server is working
            Status: ✅ (good)
            """
    }

    let usersController = StudentController()
    router.get("users", use: usersController.index)
    
    let scheduleController = ScheduleController()
    try router.register(collection: scheduleController)
    
    let teachersController = TeachersController()
    try router.register(collection: teachersController)
}
