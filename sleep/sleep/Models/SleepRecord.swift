import Foundation

struct SleepRecord: Identifiable, Codable {
    let id: UUID
    let sleepTime: Date
    let wakeTime: Date?
    let note: String
    
    init(id: UUID = UUID(), sleepTime: Date = Date(), wakeTime: Date? = nil, note: String = "") {
        self.id = id
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        self.note = note
    }
    
    var duration: TimeInterval? {
        guard let wakeTime = wakeTime else { return nil }
        return wakeTime.timeIntervalSince(sleepTime)
    }
} 