import Vapor

final class ScheduleResponse: BaseResponse {
    
    var id: Int
    var ownerId: Int
    
    var isTemplate: Bool
    
    var events: [EventResponse]

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case isTemplate = "is_template"
        case events
    }
    
    init(id: Int, ownerId: Int, isTemplate: Bool, events: [EventResponse]) {
        
        self.id = id
        self.ownerId = ownerId
        
        self.isTemplate = isTemplate
        
        self.events = events
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        ownerId = try values.decode(Int.self, forKey: .ownerId)
        
        isTemplate = try values.decode(Bool.self, forKey: .isTemplate)
        
        events = try values.decode([EventResponse].self, forKey: .events)
    }
}
