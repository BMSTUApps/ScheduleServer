import Vapor

final class UserResponse: DefaultResponse {
    
    var id: Int
    
    var email: String
    
    var firstName: String
    var lastName: String
    var middleName: String?
    
    var photo: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case photo
    }
    
    init(_ user: User) {
        self.id = user.id ?? -1
        
        self.email = user.email
        
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.middleName = user.middleName
        
        self.photo = user.photo
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        email = try values.decode(String.self, forKey: .email)
        
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        middleName = try values.decode(String.self, forKey: .middleName)
        
        photo = try values.decode(String.self, forKey: .photo)
    }
}
