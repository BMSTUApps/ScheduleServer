import FluentMySQL
import Vapor
import Authentication

struct UserToken: MySQLModel {
    
    var id: Int?
    var string: String
    var userID: User.ID
    
    var user: Parent<UserToken, User> {
        return parent(\.userID)
    }
}

extension UserToken: Token {
    
    typealias UserType = User
    
    static var tokenKey: WritableKeyPath<UserToken, String> {
        return \.string
    }
    
    static var userIDKey: WritableKeyPath<UserToken, User.ID> {
        return \.userID
    }
}
