import Vapor

/// Data required to create a user.
final class CreateUserRequest: BaseRequest {
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's name.
    var firstName: String
    var lastName: String
    var middleName: String?
    
    /// User's photo URL.
    var photo: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case photo
    }
    
    init(email: String, password: String, firstName: String, lastName: String, middleName: String?, photo: String?) {
        self.email = email
        
        self.password = password
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.photo = photo
    }
}

extension User {
    
    convenience init(_ request: CreateUserRequest, passwordHash: String) {
        self.init(id: nil, email: request.email, passwordHash: passwordHash, firstName: request.firstName, lastName: request.lastName, middleName: request.middleName, scheduleID: nil)
    }
}
