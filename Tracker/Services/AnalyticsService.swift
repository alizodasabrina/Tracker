//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/11/26.
//

import AppMetricaCore

// MARK: - AnalyticsEvent

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

// MARK: - AnalyticsItem

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

// MARK: - AnalyticsService

enum AnalyticsService {

    // TODO: заменить на реальный API-ключ приложения из личного кабинета AppMetrica (metrica.yandex.ru) перед сдачей.
    private static let apiKey = "00000000-0000-0000-0000-000000000000"

    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }

    static func report(_ event: AnalyticsEvent, screen: String, item: AnalyticsItem? = nil) {
        var parameters: [String: Any] = ["event": event.rawValue, "screen": screen]
        if let item {
            parameters["item"] = item.rawValue
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters, onFailure: nil)
    }
}
