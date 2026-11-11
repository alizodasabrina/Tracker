//
//  NewHabitViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 03/11/26.
//

import UIKit

final class NewHabitViewModel {

    // MARK: - Constants

    static let nameMaxLength = 38

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
    let completedDaysCount: Int?

    var isEditing: Bool { editingTrackerId != nil }

    private let editingTrackerId: UUID?

    private(set) var name: String = "" {
        didSet { onStateChanged?(()) }
    }

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

    var isNameTooLong: Bool {
        name.count > Self.nameMaxLength
    }

    var isCreateButtonEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isNameTooLong
            && selectedEmojiIndex != nil
            && selectedColorIndex != nil
            && selectedCategoryTitle != nil
            && !schedule.isEmpty
    }

    var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        return schedule.count == WeekDay.allCases.count
            ? NSLocalizedString("schedule_every_day", comment: "Подпись расписания, когда выбраны все дни недели")
            : schedule.map(\.shortTitle).joined(separator: ", ")
    }

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.editingTrackerId = nil
        self.completedDaysCount = nil
    }

    init(categoryStore: TrackerCategoryStore, editing tracker: Tracker, categoryTitle: String, completedDaysCount: Int) {
        self.categoryStore = categoryStore
        self.editingTrackerId = tracker.id
        self.completedDaysCount = completedDaysCount
        self.name = tracker.title
        self.schedule = tracker.schedule
        self.selectedEmojiIndex = emojis.firstIndex(of: tracker.emoji)
        self.selectedColorIndex = colors.firstIndex { Self.colorsMatch($0, tracker.color) }
        self.selectedCategoryTitle = categoryTitle
    }

    // MARK: - Private Methods

    /// Сравниваем цвета по RGB-компонентам, а не через `UIColor.isEqual`:
    /// `isEqual` требует совпадения цветового пространства, а `UIColor(resource:)`
    /// и `UIColor(red:green:blue:alpha:)` (восстановленный из hex цвет трекера) его не совпадают,
    /// хотя визуально это один и тот же цвет.
    private static func colorsMatch(_ lhs: UIColor, _ rhs: UIColor, tolerance: CGFloat = 0.01) -> Bool {
        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
        var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0, ra: CGFloat = 0
        lhs.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        rhs.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
        return abs(lr - rr) < tolerance && abs(lg - rg) < tolerance && abs(lb - rb) < tolerance
    }

    // MARK: - Public Methods

    func setName(_ text: String) {
        name = text
    }

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

    func makeTracker() -> Tracker? {
        let normalizedTitle = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !normalizedTitle.isEmpty,
            !isNameTooLong,
            let emojiIndex = selectedEmojiIndex,
            let colorIndex = selectedColorIndex
        else {
            return nil
        }

        return Tracker(
            id: editingTrackerId ?? UUID(),
            title: normalizedTitle,
            color: colors[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: schedule
        )
    }
}
