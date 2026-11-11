//
//  StatCardView.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 04/11/26.
//

import UIKit

final class StatCardView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let sideInset: CGFloat = 12
        static let valueFontSize: CGFloat = 34
        static let titleFontSize: CGFloat = 12
    }

    // MARK: - Private Properties

    private let gradientBorderLayer = CAGradientLayer()
    private let gradientMaskLayer = CAShapeLayer()

    // MARK: - Subviews

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Constants.valueFontSize)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = Constants.cornerRadius
        setupGradientBorder()
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = bounds
        gradientMaskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: Constants.borderWidth / 2, dy: Constants.borderWidth / 2),
            cornerRadius: Constants.cornerRadius
        ).cgPath
    }

    // MARK: - Public Methods

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }

    // MARK: - Private Methods

    private func setupGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor(resource: .ypRed).cgColor,
            UIColor(resource: .ypGreen).cgColor,
            UIColor(resource: .ypBlue).cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)

        gradientMaskLayer.fillColor = UIColor.clear.cgColor
        gradientMaskLayer.strokeColor = UIColor.black.cgColor
        gradientMaskLayer.lineWidth = Constants.borderWidth
        gradientBorderLayer.mask = gradientMaskLayer

        layer.addSublayer(gradientBorderLayer)
    }

    private func setupView() {
        addSubview(valueLabel)
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.sideInset),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sideInset),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sideInset),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sideInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sideInset)
        ])
    }
}
