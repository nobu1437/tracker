import Foundation

extension Date {
    func stripped() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
extension Date {
    var weekday: Weekday {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: self)
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday 
        }
    }
}
