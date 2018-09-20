import FluentMySQL
import Vapor

/// A subject.
final class Subject: MySQLModel {
    
    var id: Int?
    var name: String
    
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

/// Define coding keys for `Subject`.
extension Subject {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

/// Allows `Subject` to be used as a migration.
extension Subject: Migration { }

/// Allows `Subject` to be encoded to and decoded from HTTP messages.
extension Subject: Content { }

/// Allows `Subject` to be used as a dynamic parameter in route definitions.
extension Subject: Parameter { }
