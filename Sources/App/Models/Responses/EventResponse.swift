import Vapor

final class EventResponse: Response {

    var id: Int
    
    var name: String
    
    var kind: String
    var location: String
    
    var teacher: TeacherShortResponse
    
    var startTime: String
    var endTime: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kind
        case location
        case teacher
        case startTime = "start_time"
        case endTime = "end_time"
    }
    
    init(id: Int, name: String, kind: String, location: String, teacher: TeacherShortResponse, startTime: String, endTime: String) {
        self.id = id
        
        self.name = name
        
        self.kind = kind
        self.location = location
        
        self.teacher = teacher
        
        self.startTime = startTime
        self.endTime = endTime
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        kind = try values.decode(String.self, forKey: .kind)
        location = try values.decode(String.self, forKey: .location)
        teacher = try values.decode(TeacherShortResponse.self, forKey: .teacher)
        startTime = try values.decode(String.self, forKey: .startTime)
        endTime = try values.decode(String.self, forKey: .endTime)
    }
}
