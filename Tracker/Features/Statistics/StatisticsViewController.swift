//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/09/26.
//

import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let cardHeight: CGFloat = 90
        static let placeholderImageSize: CGFloat = 80
        static let placeholderSpacing: CGFloat = 8
        static let placeholderFontSize: CGFloat = 12
        static let emptyPlaceholderText = "Анализировать пока нечего"
        static let completedTitle = "Завершено"
    }

    // MARK: - Private Properties

    private let viewModel = StatisticsViewModel(recordStore: TrackerRecordStore())

    // MARK: - Subviews

    private lazy var completedCard: StatCardView = {
        let card = StatCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .placeholderError))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emptyPlaceholderText
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
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupView()
        setupConstraints()
        bindViewModel()
        updateState()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubview(completedCard)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completedCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            completedCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            completedCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            completedCard.heightAnchor.constraint(equalToConstant: Constants.cardHeight),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.placeholderImageSize),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: Constants.placeholderSpacing),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] _ in
            self?.updateState()
        }
    }

    private func updateState() {
        completedCard.configure(value: "\(viewModel.completedCount)", title: Constants.completedTitle)
        completedCard.isHidden = viewModel.isEmpty
        placeholderImageView.isHidden = !viewModel.isEmpty
        placeholderLabel.isHidden = !viewModel.isEmpty
    }
}
