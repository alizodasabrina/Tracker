//
//  WeekDay.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import Foundation

// rawValue как у Calendar.weekday - воскресенье = 1, чтобы не пересчитывать вручную
enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var title: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
}
