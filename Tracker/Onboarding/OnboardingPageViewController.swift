//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 24/09/26.
//

import UIKit

final class OnboardingPageViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let titleFontSize: CGFloat = 32
        static let titleSideInset: CGFloat = 16
        static let titleBottomInset: CGFloat = 160
    }

    // MARK: - Private Properties

    private let pageTitle: String
    private let backgroundImageName: String

    // MARK: - Subviews

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: backgroundImageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = pageTitle
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(title: String, backgroundImageName: String) {
        self.pageTitle = title
        self.backgroundImageName = backgroundImageName
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleSideInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleSideInset),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.titleBottomInset)
        ])
    }
}
