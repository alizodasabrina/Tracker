//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 03/11/26.
//

import Foundation

final class ScheduleViewModel {

    // MARK: - Public Properties

    // Отображаем с понедельника, а не в порядке rawValue (там неделя начинается с воскресенья).
    let weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var orderedSelectedDays: [WeekDay] {
        weekDays.filter { selectedDays.contains($0) }
    }

    // MARK: - Private Properties

    private var selectedDays: Set<WeekDay>

    // MARK: - Init

    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
    }

    // MARK: - Public Methods

    func isDaySelected(_ day: WeekDay) -> Bool {
        selectedDays.contains(day)
    }

    func setDay(_ day: WeekDay, isSelected: Bool) {
        if isSelected {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}
