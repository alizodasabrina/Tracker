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
        static let emptyPlaceholderText = NSLocalizedString("trackers_empty_placeholder", comment: "Плейсхолдер пустого списка трекеров")
        static let noResultsPlaceholderText = NSLocalizedString("trackers_no_results_placeholder", comment: "Плейсхолдер при отсутствии результатов поиска")
        static let filtersButtonWidth: CGFloat = 114
        static let filtersButtonHeight: CGFloat = 50
        static let filtersButtonCornerRadius: CGFloat = 16
        static let filtersButtonBottomInset: CGFloat = 16
    }

    // MARK: - Private Properties

    private let viewModel = TrackersViewModel(
        categoryStore: TrackerCategoryStore(),
        trackerStore: TrackerStore(),
        recordStore: TrackerRecordStore()
    )

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
        button.tintColor = .label
        return button
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = NSLocalizedString("trackers_search_placeholder", comment: "Плейсхолдер поля поиска")
        return controller
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
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
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // TODO: цвет фона кнопки «Фильтры» (ypBlue) не сверен с Figma в этой сессии — лимит инструмента; проверить при следующем доступе.
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters_title", comment: "Заголовок/кнопка фильтров"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = UIColor(resource: .ypBlue)
        button.layer.cornerRadius = Constants.filtersButtonCornerRadius
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupView()
        setupConstraints()
        setupCollectionView()
        bindViewModel()
        updatePlaceholderVisibility()
    }

    // MARK: - Actions

    @objc private func didTapAddButton() {
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationController, animated: true)
    }

    private func presentEditFlow(for tracker: Tracker) {
        guard let categoryTitle = viewModel.categoryTitle(forTrackerId: tracker.id) else { return }
        let newHabitViewController = NewHabitViewController(
            categoryStore: TrackerCategoryStore(),
            editing: tracker,
            categoryTitle: categoryTitle,
            completedDaysCount: viewModel.completedDaysCount(trackerId: tracker.id)
        )
        newHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationController, animated: true)
    }

    private func confirmDelete(trackerId: UUID) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("tracker_delete_confirm_message", comment: "Текст подтверждения удаления трекера"),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("tracker_delete_confirm_delete", comment: "Кнопка подтверждения удаления трекера"),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteTracker(id: trackerId)
        })
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("tracker_delete_confirm_cancel", comment: "Кнопка отмены удаления трекера"),
            style: .cancel
        ))
        present(alert, animated: true)
    }

    @objc private func dateChanged() {
        viewModel.setCurrentDate(datePicker.date)
    }

    @objc private func didTapFiltersButton() {
        let filterViewController = FilterViewController(currentFilter: viewModel.currentFilter)
        filterViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filterViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = NSLocalizedString("tab_trackers", comment: "Заголовок экрана трекеров")
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
        view.addSubview(filtersButton)
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
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.filtersButtonBottomInset),
            filtersButton.widthAnchor.constraint(equalToConstant: Constants.filtersButtonWidth),
            filtersButton.heightAnchor.constraint(equalToConstant: Constants.filtersButtonHeight)
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

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] _ in
            self?.collectionView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }

    private func updatePlaceholderVisibility() {
        let isEmpty = viewModel.isEmpty
        placeholderLabel.text = viewModel.isFilteringActive ? Constants.noResultsPlaceholderText : Constants.emptyPlaceholderText
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        filtersButton.isHidden = !viewModel.isFilterButtonVisible
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sectionsCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemsCount(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell,
            let tracker = viewModel.tracker(inSection: indexPath.section, row: indexPath.row)
        else {
            return UICollectionViewCell()
        }

        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompletedToday: viewModel.isCompletedToday(trackerId: tracker.id),
            completedDaysCount: viewModel.completedDaysCount(trackerId: tracker.id),
            isCompletionEnabled: viewModel.isCompletionEnabled
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let title = viewModel.categoryTitle(at: indexPath.section),
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? TrackerSectionHeaderView
        else {
            return UICollectionReusableView()
        }
        header.headerText = title
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

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let tracker = viewModel.tracker(inSection: indexPath.section, row: indexPath.row) else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: NSLocalizedString("tracker_context_edit", comment: "Пункт контекстного меню «Редактировать»")
            ) { _ in
                self?.presentEditFlow(for: tracker)
            }
            let deleteAction = UIAction(
                title: NSLocalizedString("tracker_context_delete", comment: "Пункт контекстного меню «Удалить»"),
                attributes: .destructive
            ) { _ in
                self?.confirmDelete(trackerId: tracker.id)
            }
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func trackerCell(_ cell: TrackerCollectionViewCell, didTapCompleteButtonFor trackerId: UUID) {
        viewModel.toggleCompletion(trackerId: trackerId)
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ viewController: NewHabitViewController, didSave tracker: Tracker, categoryTitle: String) {
        viewModel.saveTracker(tracker, categoryTitle: categoryTitle)
        viewController.dismiss(animated: true)
    }
}

// MARK: - FilterViewControllerDelegate

extension TrackersViewController: FilterViewControllerDelegate {
    func filterViewController(_ viewController: FilterViewController, didSelect filter: TrackerFilter) {
        viewModel.setFilter(filter)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.setSearchText(searchController.searchBar.text ?? "")
    }
}
