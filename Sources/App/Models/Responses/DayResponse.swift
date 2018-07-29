import Vapor

final class DayResponse: Response {

    var date: String
    var events: [EventResponse]
    
    enum CodingKeys: String, CodingKey {
        case date
        case events
    }
    
    init(date: String, events: [EventResponse]) {
        self.date = date
        self.events = events
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        date = try values.decode(String.self, forKey: .date)
        events = try values.decode([EventResponse].self, forKey: .events)
    }
}
