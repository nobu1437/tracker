import Foundation

class TrackerRecord{
    let trackerId: UUID
    var date: [Date]
    
    init(trackerId: UUID, date: [Date]) {
        self.trackerId = trackerId
        self.date = date
    }
}
