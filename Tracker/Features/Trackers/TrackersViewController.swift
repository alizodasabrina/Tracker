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
        button.tintColor = UIColor(resource: .ypBlack)
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

    @objc private func dateChanged() {
        viewModel.setCurrentDate(datePicker.date)
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

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] _ in
            self?.collectionView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }

    private func updatePlaceholderVisibility() {
        let isEmpty = viewModel.isEmpty
        placeholderLabel.text = viewModel.isSearchActive ? Constants.noResultsPlaceholderText : Constants.emptyPlaceholderText
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
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

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func trackerCell(_ cell: TrackerCollectionViewCell, didTapCompleteButtonFor trackerId: UUID) {
        viewModel.toggleCompletion(trackerId: trackerId)
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ viewController: NewHabitViewController, didCreate tracker: Tracker, categoryTitle: String) {
        viewModel.addTracker(tracker, categoryTitle: categoryTitle)
        viewController.dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.setSearchText(searchController.searchBar.text ?? "")
    }
}
