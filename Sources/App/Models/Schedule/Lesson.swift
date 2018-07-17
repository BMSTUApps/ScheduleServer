import FluentMySQL
import Vapor

/// A lesson.
final class Lesson: MySQLModel, Encodable {
    
    enum Kind: String {
        case lecture, seminar, lab, other = ""
    }
    
    /// The unique identifier for this lesson.
    var id: Int?
    
    /// A link to lesson's subject
    var subjectID: Int
    
    /// The lesson's kind.
    var kind: String
    
    /// A link to lesson's teacher
    var teacherID: Int

    /// The lesson's start time.
    var startTime: String

    /// The lesson's end time.
    var endTime: String

    /// The lesson's location.
    var location: String

    /// A link to lesson's schedule
    var scheduleID: Int
    
    /// Creates a new lesson.
    init(id: Int? = nil, subjectID: Int, kind: Kind, teacherID: Int, startTime: String, endTime: String, location: String, scheduleID: Int) {
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
