//
//  TrackersViewControllerSnapshotTests.swift
//  TrackerTests
//
//  Created by Sabrina Mavlyanova on 05/11/26.
//

import XCTest
import SnapshotTesting
@testable import Tracker

@MainActor
final class TrackersViewControllerSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        removeAllTrackers()
    }

    func testMainScreenLight() {
        assertSnapshot(matching: makeViewController(), as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testMainScreenDark() {
        assertSnapshot(matching: makeViewController(), as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Private Methods

    private func makeViewController() -> UIViewController {
        let viewController = TrackersViewController()
        viewController.loadViewIfNeeded()
        viewController.view.frame = UIScreen.main.bounds
        viewController.view.layoutIfNeeded()
        return viewController
    }

    /// Очищаем персистентное хранилище перед каждым тестом,
    /// чтобы снимок главного экрана был детерминирован (пустое состояние).
    private func removeAllTrackers() {
        let categoryStore = TrackerCategoryStore()
        let trackerStore = TrackerStore()
        for category in categoryStore.categories {
            for tracker in category.trackers {
                try? trackerStore.deleteTracker(withId: tracker.id)
            }
        }
    }
}
