import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("hello") { req in
        return "Hello, world!"
    }

    let usersController = StudentController()
    router.get("users", use: usersController.index)
    
    let scheduleController = ScheduleController()
    router.get("schedule", use: scheduleController.index)
    router.post("schedule/create", use: scheduleController.createSchedule)
    
    let teachersController = TeachersController()
    try router.register(collection: teachersController)
}
