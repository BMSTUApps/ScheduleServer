import Vapor

final class EventResponse: Response {

    var id: Int
    
    var title: String
    
    var kind: String
    var location: String
    
    var date: String
    var repeatIn: Int?
    var endDate: String?
    
    var startTime: String
    var endTime: String
    
    var teacher: TeacherShortResponse?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case kind
        case location
        case date
        case repeatIn = "repeat_in"
        case endDate = "end_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case teacher
    }
    
    init(id: Int, title: String, kind: String, location: String, date: Date, repeatIn: Int, endDate: Date, startTime: String, endTime: String, teacher: TeacherShortResponse) {
        self.id = id
        
        self.title = title
        
        self.kind = kind
        self.location = location

        self.date = date.string() ?? "null"
        self.repeatIn = (repeatIn == 0) ? nil : repeatIn
        self.endDate = endDate.string()
        
        self.startTime = startTime
        self.endTime = endTime
        
        self.teacher = teacher
    }
    
    init(_ event: Event) {
        self.id = event.id ?? -1
        
        self.title = event.title
        
        self.kind = event.kind
        self.location = event.location
        
        self.date = event.date.string() ?? "null"
        self.repeatIn = (event.repeatIn == 0) ? nil : event.repeatIn
        self.endDate = event.endDate?.string()
        
        self.startTime = event.startTime
        self.endTime = event.endTime
        
        //self.teacher = TeacherShortResponse(event.teacherID)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        title = try values.decode(String.self, forKey: .title)
        
        kind = try values.decode(String.self, forKey: .kind)
        location = try values.decode(String.self, forKey: .location)
        
        date = try values.decode(String.self, forKey: .date)
        repeatIn = try values.decode(Int.self, forKey: .repeatIn)
        endDate = try values.decode(String.self, forKey: .endDate)

        startTime = try values.decode(String.self, forKey: .startTime)
        endTime = try values.decode(String.self, forKey: .endTime)

        teacher = try values.decode(TeacherShortResponse.self, forKey: .teacher)
    }
}
