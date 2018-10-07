import Vapor

final class TeacherShortResponse: Response {

    var id: Int
    
    var firstName: String
    var lastName: String
    var middleName: String?
    
    var photo: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case photo
    }
    
    init(id: Int, firstName: String, lastName: String, middleName: String? = nil, photo: String? = nil) {
        self.id = id
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        
        self.photo = photo
    }
    
    init(_ teacher: Teacher) {
        self.id = teacher.id ?? -1
        
        self.firstName = teacher.firstName
        self.lastName = teacher.lastName
        self.middleName = teacher.middleName
        
        self.photo = teacher.photo
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        middleName = try values.decode(String.self, forKey: .middleName)
        
        photo = try values.decode(String.self, forKey: .photo)
    }
}
