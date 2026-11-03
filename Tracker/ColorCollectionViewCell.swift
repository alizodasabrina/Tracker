//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 28/09/26.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "ColorCollectionViewCell"

    private enum Constants {
        static let cellCornerRadius: CGFloat = 12
        static let colorViewCornerRadius: CGFloat = 8
        static let colorViewInset: CGFloat = 6
        static let borderWidth: CGFloat = 3
        static let borderAlpha: CGFloat = 0.3
    }

    // MARK: - Public Properties

    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? Constants.borderWidth : 0
            contentView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(Constants.borderAlpha).cgColor
        }
    }

    // MARK: - Subviews

    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.colorViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Constants.cellCornerRadius
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(colorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.colorViewInset),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.colorViewInset),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.colorViewInset),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.colorViewInset)
        ])
    }
}
