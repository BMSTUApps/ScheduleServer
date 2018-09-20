import Vapor

final class ScheduleResponse: Response {
    
    var id: Int
    
    var offset: Int
    var count: Int
    
    var studentId: Int
    
    var days: [DayResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case offset
        case count
        case studentId = "student_id"
        case days
    }
    
    init(id: Int, offset: Int, count: Int, studentId: Int, days: [DayResponse]) {
        self.id = id
        
        self.offset = offset
        self.count = count
        
        self.studentId = studentId
        
        self.days = days
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        offset = try values.decode(Int.self, forKey: .offset)
        count = try values.decode(Int.self, forKey: .count)
        studentId = try values.decode(Int.self, forKey: .studentId)
        days = try values.decode([DayResponse].self, forKey: .days)
    }
}
