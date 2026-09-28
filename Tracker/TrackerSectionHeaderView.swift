//
//  TrackerSectionHeaderView.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 24/09/26.
//

import UIKit

final class TrackerSectionHeaderView: UICollectionReusableView {

    // MARK: - Public Properties

    static let reuseIdentifier = "header"

    var headerText: String? {
        didSet { titleLabel.text = headerText }
    }

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
