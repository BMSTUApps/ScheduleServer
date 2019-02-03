import FluentMySQL
import Vapor

class ServerDateManager {
    
    static var semesterStartDate: Date? {
        return shared.getDate(for: semesterStartDateKey)
    }
    
    static var semesterEndDate: Date? {
        return shared.getDate(for: semesterEndDateKey)
    }
    
    static var lastScheduleUpdate: Date? {
        return shared.getDate(for: lastScheduleUpdateKey)
    }
    
    private static let semesterStartDateKey = "semesterStartDate"
    private static let semesterEndDateKey = "semesterEndDate"
    private static let lastScheduleUpdateKey = "lastScheduleUpdate"
    
    private static let shared = ServerDateManager()
    
    func getDate(for key: String) -> Date? {
        
        do {
            let connection = try app(.detect()).newConnection(to: .mysql).wait()
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
