import FluentMySQL
import Vapor

/// A subject.
final class Subject: MySQLModel {
    
    /// The unique identifier for this subject.
    var id: Int?
    
    /// The subject's name.
    var name: String
    
    /// Creates a new subject.
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

/// Allows `Subject` to be used as a migration.
extension Subject: Migration { }

/// Allows `Subject` to be encoded to and decoded from HTTP messages.
extension Subject: Content { }

/// Allows `Subject` to be used as a dynamic parameter in route definitions.
extension Subject: Parameter { }
