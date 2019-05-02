import Foundation
import Vapor
import Fluent

class ScheduleService {
    
    private let parser: ScheduleParser = ScheduleRegexParser()
    private let queue = DispatchQueue(label: "ru.bestK1ng.schedule", qos: .utility)
    
    func updateSchedules() {
        queue.asyncAfter(deadline: .now() + 5) {
//            self.removeSchedules()

            self.parser.availableGroups(completion: { groups in
                
                let testGroups = groups.prefix(upTo: 1)
                testGroups.forEach({ group in
                    self.parser.parseSchedule(for: group, completion: { schedule in
                        guard let schedule = schedule else {
                            print("Error: Empty schedule")
                            return
                        }
                        self.saveSchedule(raw: schedule)
                        print("Save schedule \(schedule.group.identifier)")
                    })
                })
                
            })
            
//            var testCount = 0
//            self.parser.parseSchedules(completion: { schedule in
//                if testCount >= 4 {
//                    return
//                }
//                testCount += 1
//
//                guard let schedule = schedule else {
//                    print("Error: Empty schedule")
//                    return
//                }
//                self.saveSchedule(raw: schedule)
//            })
        }
    }
    
    private func removeSchedules() {
        
        do {
            let environment = try Environment.detect()
            
            try app(environment).withNewConnection(to: .mysql) { connection -> EventLoopFuture<Void> in
                return Schedule.query(on: connection).delete()
            }
            
            try app(environment).withNewConnection(to: .mysql) { connection -> EventLoopFuture<Void> in
                return Group.query(on: connection).delete()
            }
            
            try app(environment).withNewConnection(to: .mysql) { connection -> EventLoopFuture<Void> in
                return Event.query(on: connection).delete()
            }
            
        } catch let error {
            print("Error with removing schedules tables: \(error)")
        }
    }
    
    private func saveSchedule(raw: RawSchedule) {
        do {
            let environment = try Environment.detect()
            _ = try app(environment).newConnection(to: .mysql).do({ connection in
                print("\(connection)")
            })
            
            let connection = try app(environment).newConnection(to: .mysql).wait()
            
            // Create schedule
            let schedule = Schedule(isTemplate: true)
            try schedule.save(on: connection).wait()
            
            // Create group
            guard let scheduleID = schedule.id else { return }
            guard let group = Group(identificator: raw.group.identifier, scheduleID: scheduleID) else { return }
            try group.save(on: connection).wait()
            
            // Create events
//            let events: [Event] = {
//                var events:
//
//                return []
//            }()
            
            defer { connection.close() }
            
        } catch let error {
            print("Error")
        }
    }
}
