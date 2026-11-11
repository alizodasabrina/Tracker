//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 05/11/26.
//

import AppMetricaCore

enum AnalyticsService {

    static func activate() {
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "APPMETRICA_API_KEY") as? String,
            !apiKey.isEmpty,
            let configuration = AppMetricaConfiguration(apiKey: apiKey)
        else { return }
        AppMetrica.activate(with: configuration)
    }

    static func report(_ event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var parameters: [String: Any] = ["event": event.rawValue, "screen": screen.rawValue]
        if let item {
            parameters["item"] = item.rawValue
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters, onFailure: nil)
    }
}
