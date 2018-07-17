import FluentMySQL
import Vapor

/// A schedule.
final class Schedule: MySQLModel {
    
    /// The unique identifier for this schedule.
    var id: Int?
    
    /// A link to schedule's lessons
    /// ...
}
