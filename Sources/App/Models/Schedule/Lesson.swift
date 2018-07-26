import FluentMySQL
import Vapor

/// A lesson.
final class Lesson: MySQLModel {
    
    enum Kind: String {
        case lecture, seminar, lab, other = ""
    }
    
    var id: Int?
    
    var kind: String
    var startTime: String
    var endTime: String
    var location: String

    var subjectID: Subject.ID
    var teacherID: Teacher.ID
    var scheduleID: Schedule.ID
    
    init(id: Int? = nil, subjectID: Subject.ID, kind: Kind, teacherID: Teacher.ID, startTime: String, endTime: String, location: String, scheduleID: Schedule.ID) {
        self.id = id
        self.subjectID = subjectID
        self.kind = kind.rawValue
        self.teacherID = teacherID
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.scheduleID = scheduleID
    }
}

/// Allows `Lesson` to be used as a migration.
extension Lesson: Migration { }

/// Allows `Lesson` to be encoded to and decoded from HTTP messages.
extension Lesson: Content { }

/// Allows `Lesson` to be used as a dynamic parameter in route definitions.
extension Lesson: Parameter { }
