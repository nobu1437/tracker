import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let isRegular: Bool
    let isPinned: Bool
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: [Weekday], isRegular: Bool, isPinned: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isRegular = isRegular
        self.isPinned = isPinned
    }
}

public enum Weekday: CaseIterable, Hashable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var title: String {
        switch self {
        case .monday: return NSLocalizedString("weekday.full.monday", comment: "")
        case .tuesday: return NSLocalizedString("weekday.full.tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekday.full.wednesday", comment: "")
        case .thursday: return NSLocalizedString("weekday.full.thursday", comment: "")
        case .friday: return NSLocalizedString("weekday.full.friday", comment: "")
        case .saturday: return NSLocalizedString("weekday.full.saturday", comment: "")
        case .sunday: return NSLocalizedString("weekday.full.sunday", comment: "")
        }
    }
    var shortTitle: String {
        switch self {
        case .monday: return NSLocalizedString("weekday.short.monday", comment: "")
        case .tuesday: return NSLocalizedString("weekday.short.tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekday.short.wednesday", comment: "")
        case .thursday: return NSLocalizedString("weekday.short.thursday", comment: "")
        case .friday: return NSLocalizedString("weekday.short.friday", comment: "")
        case .saturday: return NSLocalizedString("weekday.short.saturday", comment: "")
        case .sunday: return NSLocalizedString("weekday.short.sunday", comment: "")
        }
    }
}
