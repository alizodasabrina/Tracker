//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 24/09/26.
//

import UIKit

final class OnboardingViewController: UIPageViewController {

    // MARK: - Constants

    private enum Constants {
        static let buttonHeight: CGFloat = 60
        static let buttonSideInset: CGFloat = 20
        static let buttonBottomInset: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 16
        static let pageControlBottomInset: CGFloat = 24
    }

    // MARK: - Private Properties

    private lazy var pages: [UIViewController] = [
        OnboardingPageViewController(
            title: "Отслеживайте только то, что хотите",
            backgroundImageName: "onboarding_page1"
        ),
        OnboardingPageViewController(
            title: "Даже если это не литры воды и йога",
            backgroundImageName: "onboarding_page2"
        )
    ]

    // MARK: - Subviews

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .ypBlack)
        pageControl.pageIndicatorTintColor = UIColor(resource: .ypGray)
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }

        setupView()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func didTapContinueButton() {
        switchToTabBarController()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubview(pageControl)
        view.addSubview(continueButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonSideInset),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonSideInset),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomInset),
            continueButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -Constants.pageControlBottomInset)
        ])
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
        else { return }
        window.rootViewController = TabBarController()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentViewController = viewControllers?.first,
              let index = pages.firstIndex(of: currentViewController)
        else { return }
        pageControl.currentPage = index
    }
}
