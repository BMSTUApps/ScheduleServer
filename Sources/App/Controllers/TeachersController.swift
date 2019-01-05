import Vapor
import Fluent

/// Controls operations on 'Teacher'.
final class TeachersController: RouteCollection {

    func boot(router: Router) throws {
        let teachersRoute = router.grouped("api", "teachers")
        
        // REQUEST: api/teachers/
        teachersRoute.get(use: getTeachers)

        // REQUEST: api/teachers/teacher
        teachersRoute.get("teacher", use: getTeacher)
    }
    
    /// Returns teachers for department.
    func getTeachers(_ req: Request) throws -> Future<[Teacher]> {
        
        guard let searchDepartment = req.query[String.self, at: Teacher.CodingKeys.department.stringValue] else {
            throw Abort.missingParameters([Teacher.CodingKeys.department.stringValue])
        }
        
        return Teacher.query(on: req).filter(\.department == searchDepartment).all()
    }
    
    /// Returns teacher by id.
    func getTeacher(_ req: Request) throws -> Future<Teacher> {
        
        guard let teacherID = Int(req.query[String.self, at: Teacher.CodingKeys.id.stringValue] ?? "") else {
            throw Abort.missingParameters([Teacher.CodingKeys.id.stringValue])
        }
        
        return Teacher.find(teacherID, on: req).unwrap(or: Abort(.notFound, reason: "Teacher not found."))
    }
}

