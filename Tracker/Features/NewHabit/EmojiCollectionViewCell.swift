//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 28/09/26.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "EmojiCollectionViewCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let emojiFontSize: CGFloat = 32
    }

    // MARK: - Public Properties

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(resource: .ypBackground) : .clear
        }
    }

    // MARK: - Subviews

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.emojiFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Constants.cornerRadius
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(emojiLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
