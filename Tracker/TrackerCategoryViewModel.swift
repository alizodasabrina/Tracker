//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 30/10/26.
//

import Foundation

final class TrackerCategoryViewModel {

    // MARK: - Public Properties

    var onCategoriesChange: Binding<[TrackerCategory]>?
    var onCategorySelected: Binding<String>?

    private(set) var selectedCategoryTitle: String?

    var categoriesCount: Int { categories.count }

    // MARK: - Private Properties

    private let categoryStore: TrackerCategoryStore

    private var categories: [TrackerCategory] = [] {
        didSet { onCategoriesChange?(categories) }
    }

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore.delegate = self
        self.categories = categoryStore.categories
    }

    // MARK: - Public Methods

    func categoryTitle(at index: Int) -> String? {
        categories[safe: index]?.title
    }

    func isCategorySelected(at index: Int) -> Bool {
        categoryTitle(at: index) != nil && categoryTitle(at: index) == selectedCategoryTitle
    }

    func selectCategory(at index: Int) {
        guard let title = categoryTitle(at: index) else { return }
        selectedCategoryTitle = title
        onCategorySelected?(title)
    }

    func isCategoryNameAvailable(_ title: String) -> Bool {
        !categories.contains { $0.title.caseInsensitiveCompare(title) == .orderedSame }
    }

    func addCategory(title: String) throws {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty, isCategoryNameAvailable(normalizedTitle) else { return }
        try categoryStore.addNewCategory(TrackerCategory(title: normalizedTitle, trackers: []))
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        categories = store.categories
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
