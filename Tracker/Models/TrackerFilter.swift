//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/11/26.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filter_all", comment: "Фильтр «Все трекеры»")
        case .today:
            return NSLocalizedString("filter_today", comment: "Фильтр «Трекеры на сегодня»")
        case .completed:
            return NSLocalizedString("filter_completed", comment: "Фильтр «Завершённые»")
        case .incomplete:
            return NSLocalizedString("filter_incomplete", comment: "Фильтр «Незавершённые»")
        }
    }

    /// Выбор этих двух фильтров — одноразовое действие (сброс/переход на сегодня),
    /// поэтому в отличие от «Завершённые»/«Незавершённые» они не остаются отмеченными галочкой.
    var isPersistentSelection: Bool {
        self == .completed || self == .incomplete
    }
}
