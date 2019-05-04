import FluentMySQL
import Vapor

class ServerDateService {
    
    static let calendar = Calendar.init(identifier: .iso8601)
    static let dateFormat = "dd.MM.yyyy"
    
    static var semesterStartDate: Date? {
        return shared.getDate(for: semesterStartDateKey)
    }
    
    static var semesterEndDate: Date? {
        return shared.getDate(for: semesterEndDateKey)
    }
    
    static var lastScheduleUpdate: Date? {
        return shared.getDate(for: lastScheduleUpdateKey)
    }
    
    private static let semesterStartDateKey = "semester_start"
    private static let semesterEndDateKey = "semester_end"
    private static let lastScheduleUpdateKey = "last_schedules_update"
    
    private static let shared = ServerDateService()
    
    func getDate(for key: String) -> Date? {
        
        do {
            let environment = try Environment.detect()
            let currentApp = try app(environment)
            let connection = try currentApp.newConnection(to: .mysql).wait()
            let date = try ServerDate.query(on: connection).filter(\.key == key).first().unwrap(or: Abort(.notFound, reason: "Date with key '\(key)' not found")).wait()
            
            defer {
               connection.close()
            }
            
            return date.value
            
        } catch let error {

            // TODO: Handle error

            return nil
        }
    }
}
