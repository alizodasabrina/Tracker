//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 04/11/26.
//

import Foundation

final class StatisticsViewModel {

    // MARK: - Bindings

    var onDataChanged: Binding<Void>?

    // MARK: - Public Properties

    var completedCount: Int { recordStore.records.count }
    var isEmpty: Bool { completedCount == 0 }

    // MARK: - Private Properties

    private let recordStore: TrackerRecordStore

    // MARK: - Init

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        self.recordStore.delegate = self
    }
}

// MARK: - TrackerRecordStoreDelegate

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ store: TrackerRecordStore) {
        onDataChanged?(())
    }
}
