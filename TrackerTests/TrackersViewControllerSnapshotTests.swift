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

    // MARK: - Private Properties

    private var sut: TrackersViewController!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        removeAllTrackers()
        sut = TrackersViewController()
        sut.loadViewIfNeeded()
        sut.view.frame = UIScreen.main.bounds
        sut.view.layoutIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testMainScreenLight() {
        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testMainScreenDark() {
        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Private Methods

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
