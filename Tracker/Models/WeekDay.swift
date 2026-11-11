//
//  WeekDay.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import Foundation

// rawValue как у Calendar.weekday - воскресенье = 1, чтобы не пересчитывать вручную
enum WeekDay: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var title: String {
        switch self {
        case .monday: NSLocalizedString("weekday_monday_full", comment: "Понедельник, полное название")
        case .tuesday: NSLocalizedString("weekday_tuesday_full", comment: "Вторник, полное название")
        case .wednesday: NSLocalizedString("weekday_wednesday_full", comment: "Среда, полное название")
        case .thursday: NSLocalizedString("weekday_thursday_full", comment: "Четверг, полное название")
        case .friday: NSLocalizedString("weekday_friday_full", comment: "Пятница, полное название")
        case .saturday: NSLocalizedString("weekday_saturday_full", comment: "Суббота, полное название")
        case .sunday: NSLocalizedString("weekday_sunday_full", comment: "Воскресенье, полное название")
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: NSLocalizedString("weekday_monday_short", comment: "Понедельник, сокращение")
        case .tuesday: NSLocalizedString("weekday_tuesday_short", comment: "Вторник, сокращение")
        case .wednesday: NSLocalizedString("weekday_wednesday_short", comment: "Среда, сокращение")
        case .thursday: NSLocalizedString("weekday_thursday_short", comment: "Четверг, сокращение")
        case .friday: NSLocalizedString("weekday_friday_short", comment: "Пятница, сокращение")
        case .saturday: NSLocalizedString("weekday_saturday_short", comment: "Суббота, сокращение")
        case .sunday: NSLocalizedString("weekday_sunday_short", comment: "Воскресенье, сокращение")
        }
    }
}
