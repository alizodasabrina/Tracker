//
//  NewHabitViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 03/11/26.
//

import UIKit

final class NewHabitViewModel {

    // MARK: - Bindings

    var onStateChanged: Binding<Void>?

    // MARK: - Public Properties

    let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

    let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ].map { UIColor(resource: $0) }

    let categoryStore: TrackerCategoryStore

    private(set) var schedule: [WeekDay] = [] {
        didSet { onStateChanged?(()) }
    }

    private(set) var selectedEmojiIndex: Int? {
        didSet { onStateChanged?(()) }
    }

    private(set) var selectedColorIndex: Int? {
        didSet { onStateChanged?(()) }
    }

    private(set) var selectedCategoryTitle: String? {
        didSet { onStateChanged?(()) }
    }

    var isCreateButtonEnabled: Bool {
        selectedEmojiIndex != nil && selectedColorIndex != nil && selectedCategoryTitle != nil && !schedule.isEmpty
    }

    var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        return schedule.count == WeekDay.allCases.count
            ? "Каждый день"
            : schedule.map(\.shortTitle).joined(separator: ", ")
    }

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    // MARK: - Public Methods

    func selectEmoji(at index: Int) {
        selectedEmojiIndex = index
    }

    func selectColor(at index: Int) {
        selectedColorIndex = index
    }

    func selectCategory(title: String) {
        selectedCategoryTitle = title
    }

    func selectSchedule(_ days: [WeekDay]) {
        schedule = days
    }

    func makeTracker(title: String) -> Tracker? {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !normalizedTitle.isEmpty,
            let emojiIndex = selectedEmojiIndex,
            let colorIndex = selectedColorIndex
        else {
            return nil
        }

        return Tracker(
            id: UUID(),
            title: normalizedTitle,
            color: colors[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: schedule
        )
    }
}
