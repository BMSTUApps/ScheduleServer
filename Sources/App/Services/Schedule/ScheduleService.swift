import Foundation
import Vapor
import Fluent

class ScheduleService {
    
    private let parser: ScheduleParser = ScheduleRegexParser()
    private let queue = DispatchQueue(label: "ru.bestK1ng.schedule", qos: .utility)
    
    func updateSchedules() {
        
        queue.async {
            self.parser.availableGroups(completion: { groups in
                
                let testGroups = groups.prefix(upTo: 1)
                testGroups.forEach({ group in
                    self.parser.parseSchedule(for: group, completion: { schedule in
                        guard let schedule = schedule else {
                            print("Error: Empty schedule")
                            return
                        }
                        self.saveSchedules(raws: [schedule])
                        print("Saved schedule for \(schedule.group.identifier)")
                    })
                })
            })
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
            var group: Group?
            var schedule: Schedule?
            
            guard let department = raw.group.department, let number = raw.group.number else { return }

            // Find group
            group = try Group.query(on: connection).filter(\.department == department).filter(\.number == number).first().wait()
            
            // If the group isn't found
            if group == nil {
                
                // => create schedule
                schedule = Schedule(isTemplate: true)
                schedule = try schedule?.save(on: connection).wait()
                
                // => create group
                group = Group(identificator: raw.group.identifier, scheduleID: (schedule?.id)!)
                group = try group?.save(on: connection).wait()
            }
            
            guard let unwrappedGroup = group else { return }
            
            // If schedule is empty
            if schedule == nil {
                
                // Find schedule
                schedule = try Schedule.query(on: connection).filter(\.id == unwrappedGroup.scheduleID).first().wait()
                
                // If the schedule isn't found
                if schedule == nil {
                    
                    // => create schedule
                    schedule = Schedule(isTemplate: true)
                    schedule = try schedule?.save(on: connection).wait()
                    
                    // => update group
                    var unwrappedGroup = try Group.query(on: connection)
                        .filter(\.department == department)
                        .filter(\.number == number).first().wait()!
                    unwrappedGroup.scheduleID = schedule!.id!
                    unwrappedGroup = try unwrappedGroup.save(on: connection).wait()
                }
            }
            
            guard let unwrappedSchedule = schedule else { return }
            
            // Find old events from schedule and delete
            let events = try Event.query(on: connection).filter(\.scheduleID == unwrappedSchedule.id!).all().wait()
            try events.forEach { event in
                try event.delete(on: connection).wait()
            }
            
            // TODO: Save events
            
        } catch let error {
            print("Error with saving schedule \"\(raw.group.identifier)\": \(error)")
        }
    }
}
