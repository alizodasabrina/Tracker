//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/09/26.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let placeholderImageSize: CGFloat = 80
        static let placeholderSpacing: CGFloat = 8
        static let placeholderFontSize: CGFloat = 12
        static let sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        static let cellSpacing: CGFloat = 9
        static let cellsPerRow: CGFloat = 2
        static let cellHeightRatio: CGFloat = 0.88
        static let headerHeight: CGFloat = 47
        static let reuseIdentifier = "cell"
        static let emptyPlaceholderText = "Что будем отслеживать?"
        static let noResultsPlaceholderText = "Ничего не найдено"
    }

    // MARK: - Public Properties

    var categories: [TrackerCategory] = []

    var completedTrackers: [TrackerRecord] = [] {
        didSet { completedTrackersSet = Set(completedTrackers) }
    }

    var currentDate: Date = Date()

    // MARK: - Private Properties

    /// Кэш `completedTrackers` для поиска за O(1) вместо линейного перебора массива.
    private var completedTrackersSet: Set<TrackerRecord> = []

    private let defaultCategoryTitle = "Важное"
    private var searchText: String = ""

    private let categoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()

    private var visibleCategories: [TrackerCategory] {
        guard let weekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) else {
            return []
        }
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(weekDay)
                let matchesSearch = searchText.isEmpty
                    || tracker.title.localizedCaseInsensitiveContains(searchText)
                return matchesSchedule && matchesSearch
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    // MARK: - Subviews

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2 // Неделя с понедельника, как и в расписании.
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(resource: .addTracker),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(resource: .ypBlack)
        return button
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = "Поиск"
        return controller
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .placeholderError))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.placeholderFontSize, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        categoryStore.delegate = self
        recordStore.delegate = self
        setupNavigationBar()
        setupView()
        setupConstraints()
        setupCollectionView()
        reloadFromStores()
    }

    // MARK: - Actions

    @objc private func didTapAddButton() {
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationController, animated: true)
    }

    @objc private func dateChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupView() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.placeholderImageSize),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: Constants.placeholderSpacing),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.reuseIdentifier
        )
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
    }

    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        let isSearchOrFilterActive = !searchText.isEmpty
        placeholderLabel.text = isSearchOrFilterActive ? Constants.noResultsPlaceholderText : Constants.emptyPlaceholderText
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func isCompletedToday(trackerId: UUID) -> Bool {
        completedTrackersSet.contains(TrackerRecord(trackerId: trackerId, date: currentDate))
    }

    private func reloadFromStores() {
        categories = categoryStore.categories
        completedTrackers = recordStore.records
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }

    private func addTracker(_ tracker: Tracker) {
        do {
            let category = try categoryStore.categoryCoreData(withTitle: defaultCategoryTitle)
                ?? (try categoryStore.addNewCategory(TrackerCategory(title: defaultCategoryTitle, trackers: [])))
            try trackerStore.addNewTracker(tracker, to: category)
        } catch {
            assertionFailure("Не удалось сохранить трекер: \(error)")
        }
    }

    private func completedDaysCount(trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    private func isCompletionEnabled() -> Bool {
        // Нельзя отметить трекер для будущей даты.
        Calendar.current.compare(currentDate, to: Date(), toGranularity: .day) != .orderedDescending
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday(trackerId: tracker.id),
            completedDaysCount: completedDaysCount(trackerId: tracker.id),
            isCompletionEnabled: isCompletionEnabled()
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section < visibleCategories.count,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? TrackerSectionHeaderView
        else {
            return UICollectionReusableView()
        }
        header.headerText = visibleCategories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth = Constants.sectionInset.left + Constants.sectionInset.right + Constants.cellSpacing
        let availableWidth = collectionView.bounds.width - paddingWidth
        let cellWidth = availableWidth / Constants.cellsPerRow
        return CGSize(width: cellWidth, height: cellWidth * Constants.cellHeightRatio)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        Constants.sectionInset
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Constants.headerHeight)
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func trackerCell(_ cell: TrackerCollectionViewCell, didTapCompleteButtonFor trackerId: UUID) {
        guard isCompletionEnabled() else { return }

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
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ viewController: NewHabitViewController, didCreate tracker: Tracker) {
        addTracker(tracker)
        viewController.dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        reloadFromStores()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ store: TrackerRecordStore) {
        reloadFromStores()
    }
}
