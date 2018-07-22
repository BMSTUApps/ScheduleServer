import Vapor
import Fluent

/// Controls operations on 'Teacher'.
final class TeachersController: RouteCollection {

    func boot(router: Router) throws {
        let teachersRoute = router.grouped("api", "teachers")
        
        teachersRoute.get(use: getTeachers)
        teachersRoute.get("teacher", use: getTeacher)
    }
    
    /// Returns teachers for department.
    func getTeachers(_ req: Request) throws -> Future<[Teacher]> {
        
        guard let searchDepartment = req.query[String.self, at: "department"] else {
            throw Abort(.badRequest, reason: "Missing teacher department in request.")
        }
        
        return Teacher.query(on: req).filter(\.department == searchDepartment).all()
    }
    
    /// Returns teacher by id.
    func getTeacher(_ req: Request) throws -> Future<Teacher> {
        
        guard let teacherID = Int(req.query[String.self, at: "id"] ?? "Empty") else {
            throw Abort(.badRequest, reason: "Missing teacher id in request.")
        }
        
        return Teacher.find(teacherID, on: req).unwrap(or: Abort(.notFound, reason: "Teacher not found."))
    }
}

