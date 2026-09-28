//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import Foundation

// сравниваем и хэшируем по дню, без времени - чтобы Set нормально искал по дате
struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date

    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.trackerId == rhs.trackerId && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(Calendar.current.startOfDay(for: date))
    }
}
