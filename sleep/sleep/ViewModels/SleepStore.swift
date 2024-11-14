import Foundation
import SwiftUI

class SleepStore: ObservableObject {
    @Published var sleepRecords: [SleepRecord] = []
    @Published var currentRecord: SleepRecord?
    
    func startSleep(note: String = "") {
        currentRecord = SleepRecord(sleepTime: Date(), note: note)
    }
    
    func endSleep() {
        guard var record = currentRecord else { return }
        record = SleepRecord(id: record.id, 
                           sleepTime: record.sleepTime, 
                           wakeTime: Date(), 
                           note: record.note)
        sleepRecords.append(record)
        currentRecord = nil
        
        // 这里可以添加数据持久化逻辑
    }
} 