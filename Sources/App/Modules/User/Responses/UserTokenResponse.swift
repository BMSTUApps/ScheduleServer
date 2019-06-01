import Vapor

final class UserTokenResponse: BaseResponse {
    
    static let defaultFormat = "yyyy-MM-dd HH:mm:ss"
    
    var id: Int
    
    var userID: Int
    var expiresAt: String?
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case expiresAt = "expires_at"
        case token
    }
    
    init(_ token: UserToken) {
        self.id = token.id ?? -1
        
        self.userID = token.userID
        self.token = token.string
                
        if let expireDate = token.expiresAt {
            self.expiresAt = defaultDateFormatter.string(from: expireDate)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        userID = try values.decode(Int.self, forKey: .userID)
        expiresAt = try values.decode(String.self, forKey: .expiresAt)
        token = try values.decode(String.self, forKey: .token)
    }
    
    private var defaultDateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = UserTokenResponse.defaultFormat

        return formatter
    }
}
