//
//  TabBarController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/09/26.
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let unselectedColor = UIColor(resource: .ypGray)
        let selectedColor = UIColor(resource: .ypBlue)

        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill")?.withTintColor(unselectedColor, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "record.circle.fill")?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
        )
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabStatistics).withTintColor(unselectedColor, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(resource: .tabStatistics).withTintColor(selectedColor, renderingMode: .alwaysOriginal)
        )

        viewControllers = [trackersNavigationController, statisticsViewController]

        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = unselectedColor

        for item in [trackersViewController.tabBarItem, statisticsViewController.tabBarItem] {
            item?.setTitleTextAttributes([.foregroundColor: unselectedColor], for: .normal)
            item?.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)
        }
    }
}
