//
//  OnboardingService.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 30/10/26.
//

import Foundation

final class OnboardingService {

    static let shared = OnboardingService()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    private init() {}

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
}
