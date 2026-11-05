//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 03/11/26.
//

import Foundation

final class TrackersViewModel {

    // MARK: - Bindings

    var onDataChanged: Binding<Void>?

    // MARK: - Public Properties

    private(set) var currentDate: Date = Date() {
        didSet { onDataChanged?(()) }
    }

    var sectionsCount: Int { visibleCategories.count }
    var isEmpty: Bool { visibleCategories.isEmpty }
    var isSearchActive: Bool { !searchText.isEmpty }
    var isFilteringActive: Bool { isSearchActive || currentFilter == .completed || currentFilter == .incomplete }

    private(set) var currentFilter: TrackerFilter = .all {
        didSet { onDataChanged?(()) }
    }

    var isFilterButtonVisible: Bool {
        guard let weekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) else { return false }
        return categories.contains { category in category.trackers.contains { $0.schedule.contains(weekDay) } }
    }

    var isCompletionEnabled: Bool {
        Calendar.current.compare(currentDate, to: Date(), toGranularity: .day) != .orderedDescending
    }

    // MARK: - Private Properties

    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    private var categories: [TrackerCategory] = []

    private var completedTrackers: [TrackerRecord] = [] {
        didSet { completedTrackersSet = Set(completedTrackers) }
    }

    private var completedTrackersSet: Set<TrackerRecord> = []
    private var searchText: String = ""

    private var visibleCategories: [TrackerCategory] {
        guard let weekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) else {
            return []
        }
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(weekDay)
                let matchesSearch = searchText.isEmpty
                    || tracker.title.localizedCaseInsensitiveContains(searchText)
                let matchesFilter: Bool
                switch currentFilter {
                case .all, .today:
                    matchesFilter = true
                case .completed:
                    matchesFilter = isCompletedToday(trackerId: tracker.id)
                case .incomplete:
                    matchesFilter = !isCompletedToday(trackerId: tracker.id)
                }
                return matchesSchedule && matchesSearch && matchesFilter
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore, trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.categoryStore.delegate = self
        self.recordStore.delegate = self
        reloadFromStores()
    }

    // MARK: - Public Methods

    func itemsCount(in section: Int) -> Int {
        visibleCategories[safe: section]?.trackers.count ?? 0
    }

    func tracker(inSection section: Int, row: Int) -> Tracker? {
        visibleCategories[safe: section]?.trackers[safe: row]
    }

    func categoryTitle(at section: Int) -> String? {
        visibleCategories[safe: section]?.title
    }

    func isCompletedToday(trackerId: UUID) -> Bool {
        completedTrackersSet.contains(TrackerRecord(trackerId: trackerId, date: currentDate))
    }

    func completedDaysCount(trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    func setCurrentDate(_ date: Date) {
        currentDate = date
    }

    func setSearchText(_ text: String) {
        searchText = text
        onDataChanged?(())
    }

    func setFilter(_ filter: TrackerFilter) {
        switch filter {
        case .today:
            currentFilter = .all
            currentDate = Date()
        case .all, .completed, .incomplete:
            currentFilter = filter
        }
    }

    func saveTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            let category = try categoryStore.categoryCoreData(withTitle: categoryTitle)
                ?? (try categoryStore.addNewCategory(TrackerCategory(title: categoryTitle, trackers: [])))
            if try trackerStore.trackerCoreData(withId: tracker.id) != nil {
                try trackerStore.updateTracker(tracker, category: category)
            } else {
                try trackerStore.addNewTracker(tracker, to: category)
            }
        } catch {
            assertionFailure("Не удалось сохранить трекер: \(error)")
        }
    }

    func deleteTracker(id: UUID) {
        do {
            try trackerStore.deleteTracker(withId: id)
        } catch {
            assertionFailure("Не удалось удалить трекер: \(error)")
        }
    }

    func categoryTitle(forTrackerId trackerId: UUID) -> String? {
        categories.first { category in category.trackers.contains { $0.id == trackerId } }?.title
    }

    func toggleCompletion(trackerId: UUID) {
        guard isCompletionEnabled else { return }

        do {
            if isCompletedToday(trackerId: trackerId) {
                try recordStore.deleteRecord(trackerId: trackerId, date: currentDate)
            } else if let trackerCoreData = try trackerStore.trackerCoreData(withId: trackerId) {
                try recordStore.addNewRecord(TrackerRecord(trackerId: trackerId, date: currentDate), for: trackerCoreData)
            }
        } catch {
            assertionFailure("Не удалось сохранить отметку выполнения: \(error)")
        }
    }

    // MARK: - Private Methods

    private func reloadFromStores() {
        categories = categoryStore.categories
        completedTrackers = recordStore.records
        onDataChanged?(())
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        reloadFromStores()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ store: TrackerRecordStore) {
        reloadFromStores()
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
