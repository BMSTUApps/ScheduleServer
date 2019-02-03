import FluentMySQL
import Vapor

final class ServerDate: MySQLModel {
    
    var id: Int?
    
    var key: String
    var value: Date
    
    init(id: Int? = nil, key: String, value: Date) {
        self.id = id
        
        self.key = key
        self.value = value
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        key = try values.decode(String.self, forKey: .key)
        value = try values.decode(Date.self, forKey: .value)
    }
}

/// Define coding keys for `ServerDate`.
extension ServerDate {
    
    enum CodingKeys: String, CodingKey {
        case id
        case key
        case value
    }
}

/// Allows `ServerDate` to be used as a migration.
extension ServerDate: Migration { }

/// Allows `ServerDate` to be encoded to and decoded from HTTP messages.
extension ServerDate: Content { }

/// Allows `ServerDate` to be used as a dynamic parameter in route definitions.
extension ServerDate: Parameter { }
