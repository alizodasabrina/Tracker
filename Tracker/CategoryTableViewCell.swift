//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 30/10/26.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "CategoryTableViewCell"

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .ypBackground)
        selectionStyle = .none
        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(resource: .ypBlack)
        tintColor = UIColor(resource: .ypBlue)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    func configure(title: String, isSelected: Bool) {
        textLabel?.text = title
        accessoryType = isSelected ? .checkmark : .none
    }
}
