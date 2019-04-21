import Foundation

class ScheduleService {
    
    let parser: ScheduleParser = ScheduleRegexParser()
    
    func test() {
        parser.availableGroups { (groups) in
            let group = groups[0]
            parser.parseSchedule(for: group, completion: { schedule in
                print(schedule)
            })
        }
    }
}
