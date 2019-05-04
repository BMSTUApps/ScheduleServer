import Foundation
import Vapor
import Fluent

class ScheduleService {
    
    private let parser: ScheduleParser = ScheduleRegexParser()
    private let queue = DispatchQueue(label: "ru.bestK1ng.schedule", qos: .utility)
    
    func updateSchedules() {
        
        queue.async {
            self.parser.availableGroups(completion: { groups in
                
                let testGroups = groups.suffix(1)
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
            
            // Save events
            try raw.events.forEach { raw in
                var event = raw.map(scheduleID: unwrappedSchedule.id!)
                event = try event?.save(on: connection).wait()
            }
            
        } catch let error {
            print("Error with saving schedule \"\(raw.group.identifier)\": \(error)")
        }
    }
}

private extension RawEvent {
    func map(teacherID: Teacher.ID? = nil, scheduleID: Schedule.ID) -> Event? {
        guard let startSemesterDate = ServerDateService.semesterStartDate else { return nil }
        
        let week = startSemesterDate.week
        let weekOffset: Int = {
            switch repeatKind {
            case .numerator, .both:
                return 0
            case .denominator:
                return 1
            }
        }()
        
        let repeatIn: Int = {
            switch repeatKind {
            case .numerator, .denominator:
                return 2
            case .both:
                return 1
            }
        }()
        
        var date = Date.date(of: weekday, weekNumber: week + weekOffset)
        if date < startSemesterDate {
            date = Date.date(of: weekday, weekNumber: week + 2 * weekOffset)
        }

        return Event(
            title: title,
            kind: kind.rawValue,
            location: location,
            date: date,
            repeatIn: repeatIn,
            endDate: ServerDateService.semesterEndDate,
            startTime: startTime,
            endTime: endTime,
            teacherID: 0,
            scheduleID: scheduleID
        )
    }
}
