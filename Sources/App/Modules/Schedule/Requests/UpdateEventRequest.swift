import Vapor

// Data required to update an event
final class UpdateEventRequest: BaseRequest {
    
    var id: Int
    
    var title: String
    
    var kind: String
    var location: String
    
    var date: Date
    var repeatIn: Int
    var endDate: Date?
    
    var startTime: String
    var endTime: String
    
    var teacherID: Teacher.ID
    var scheduleID: Schedule.ID
    
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
        case teacherID = "teacher_id"
        case scheduleID = "schedule_id"
    }
}
