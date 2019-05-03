import Foundation
import Vapor
import Fluent

class ScheduleService {
    
    private let parser: ScheduleParser = ScheduleRegexParser()
    private let queue = DispatchQueue(label: "ru.bestK1ng.schedule", qos: .utility)
    
    func updateSchedules() {
        
        queue.asyncAfter(deadline: .now() + 5) {

            self.parser.availableGroups(completion: { groups in
                
                let testGroups = groups.prefix(upTo: 1)
                testGroups.forEach({ group in
                    self.parser.parseSchedule(for: group, completion: { schedule in
                        guard let schedule = schedule else {
                            print("Error: Empty schedule")
                            return
                        }
                        self.saveSchedules(raws: [schedule])
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

    private func saveSchedules(raws: [RawSchedule]) {
        do {
            let environment = try Environment.detect()
            let currentApp = try app(environment)
            let connection = try currentApp.newConnection(to: .mysql).wait()

            for raw in raws {
                saveSchedule(raw: raw, on: connection)
            }
            
            connection.close()
            
        } catch let error {
            print("Error with connection to DB: \(error)")
        }
    }
    
    private func saveSchedule(raw: RawSchedule, on connection: DatabaseConnectable) {
        do {
            // Find group
            guard let department = raw.group.department, let number = raw.group.number else { return }
            let group = try Group.query(on: connection)
                .filter(\.department == department)
                .filter(\.number == number).first().map(to: Group.self, { group -> Group in
                guard let group = group else {

                    // If the group isn't found => create schedule
                    var schedule = Schedule(isTemplate: true)
                    schedule = try schedule.save(on: connection).wait()
                    
                    // Then create group
                    var group = Group(identificator: raw.group.identifier, scheduleID: schedule.id!)!
                    group = try group.save(on: connection).wait()
                    return group
                }
                
                return group
            }).wait()
            
            // Find schedule
            let schedule = try Schedule.query(on: connection).filter(\.id == group.scheduleID).first().map({ schedule -> Schedule in
                guard let schedule = schedule else {
                    
                    // If the schedule isn't found => create schedule
                    var schedule = Schedule(isTemplate: true)
                    schedule = try schedule.save(on: connection).wait()

                    // Then update group
                    let group = try Group.query(on: connection)
                        .filter(\.department == department)
                        .filter(\.number == number).first().wait()!
                    group.scheduleID = schedule.id!
                    _ = try group.save(on: connection).wait()
                    
                    return schedule
                }
                
                return schedule
            }).wait()
            
            // Find old events from schedule and delete
            let events = try Event.query(on: connection).filter(\.scheduleID == schedule.id!).all().wait()
            try events.forEach { event in
                try event.delete(on: connection).wait()
            }
            
        } catch let error {
            print("Error with saving schedule \"\(raw.group.identifier)\": \(error)")
        }
    }
}
