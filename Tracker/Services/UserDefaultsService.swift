//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 10/11/26.
//

import Foundation

final class UserDefaultsService {

    static let shared = UserDefaultsService()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let selectedTrackerFilter = "selectedTrackerFilter"
    }

    private init() {}

    var selectedTrackerFilterRawValue: Int? {
        get { defaults.object(forKey: Key.selectedTrackerFilter) as? Int }
        set { defaults.set(newValue, forKey: Key.selectedTrackerFilter) }
    }
}
