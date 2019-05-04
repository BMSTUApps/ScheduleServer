import Foundation
import Vapor
import Fluent

class ScheduleService {
    
    private let parser: ScheduleParser = ScheduleRegexParser()
    private let queue = DispatchQueue(label: "ru.bestK1ng.schedule", qos: .utility)
    
    private let sleepParserDelay: UInt32 = 1 // seconds
    private let sleepDatabaseDelay: UInt32 = 1 // seconds

    func updateSchedules() {
        queue.async {
            self.parser.availableGroups(completion: { groups in
                var index = 1
                groups.forEach({ group in
                    sleep(self.sleepParserDelay)
                    self.parser.parseSchedule(for: group, completion: { schedule in
                        guard let schedule = schedule else {
                            print("Error: Empty schedule")
                            return
                        }
                        self.saveSchedules(raws: [schedule])
                        print("\(index): Saved schedule for \(schedule.group.identifier) (\(schedule.events.count) events)")
                        index += 1
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
                var teacher: Teacher?
                
                // If we have enough data about the teacher
                if let lastName = raw.teacherLastName,
                    let firstNameChar = raw.teacherFirstNameChar,
                    let middleNameChar = raw.teacherMiddleNameChar {

                    // => find teacher
                    teacher = try Teacher.query(on: connection).filter(\.lastName == lastName).first().map({ teacher -> Teacher? in
                        
                        // If teacher data match
                        if let teacher = teacher,
                            teacher.firstName.prefix(1) == firstNameChar,
                            teacher.middleName.prefix(1) == middleNameChar {
                            return teacher
                        }
                        
                        return nil
                    }).wait()
                }
                
                var event = raw.map(teacherID: teacher?.id, scheduleID: unwrappedSchedule.id!)
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
            teacherID: teacherID ?? 0,
            scheduleID: scheduleID
        )
    }
}
