//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import UIKit

// MARK: - TrackerCollectionViewCellDelegate

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func trackerCell(_ cell: TrackerCollectionViewCell, didTapCompleteButtonFor trackerId: UUID)
}

// MARK: - TrackerCollectionViewCell

final class TrackerCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "TrackerCollectionViewCell"

    private enum Constants {
        static let cardCornerRadius: CGFloat = 16
        static let emojiSize: CGFloat = 24
        static let emojiCornerRadius: CGFloat = 12
        static let sideInset: CGFloat = 12
        static let completeButtonSize: CGFloat = 34
        static let titleFontSize: CGFloat = 12
        static let counterFontSize: CGFloat = 12
        static let completedIconName = "checkmark"
        static let incompleteIconName = "plus"
    }

    // MARK: - Public Properties

    weak var delegate: TrackerCollectionViewCellDelegate?

    // MARK: - Private Properties

    private var trackerId: UUID?

    // MARK: - Subviews

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = Constants.emojiCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.counterFontSize, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = Constants.completeButtonSize / 2
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    func configure(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDaysCount: Int,
        isCompletionEnabled: Bool
    ) {
        trackerId = tracker.id
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        completeButton.backgroundColor = isCompletedToday ? tracker.color.withAlphaComponent(0.3) : tracker.color
        completeButton.isEnabled = isCompletionEnabled

        let imageName = isCompletedToday ? Constants.completedIconName : Constants.incompleteIconName
        let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        completeButton.setImage(UIImage(systemName: imageName, withConfiguration: iconConfiguration), for: .normal)

        counterLabel.text = daysString(for: completedDaysCount)
    }

    // MARK: - Actions

    @objc private func didTapCompleteButton() {
        guard let trackerId else { return }
        delegate?.trackerCell(self, didTapCompleteButtonFor: trackerId)
    }

    // MARK: - Private Methods

    private func daysString(for count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10
        let word: String
        if remainder100 >= 11 && remainder100 <= 14 {
            word = "дней"
        } else if remainder10 == 1 {
            word = "день"
        } else if remainder10 >= 2 && remainder10 <= 4 {
            word = "дня"
        } else {
            word = "дней"
        }
        return "\(count) \(word)"
    }

    private func setupView() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(completeButton)
        contentView.addSubview(counterLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.55),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: Constants.emojiSize),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: Constants.emojiSize),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.sideInset),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.sideInset),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            completeButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),
            completeButton.widthAnchor.constraint(equalToConstant: Constants.completeButtonSize),
            completeButton.heightAnchor.constraint(equalToConstant: Constants.completeButtonSize)
        ])
    }
}
