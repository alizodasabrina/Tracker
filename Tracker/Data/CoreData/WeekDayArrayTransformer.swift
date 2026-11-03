//
//  WeekDayArrayTransformer.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 29/10/26.
//

import Foundation

@objc(WeekDayArrayTransformer)
final class WeekDayArrayTransformer: ValueTransformer {

    static let name = NSValueTransformerName(rawValue: String(describing: WeekDayArrayTransformer.self))

    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data)
    }

    static func register() {
        ValueTransformer.setValueTransformer(WeekDayArrayTransformer(), forName: name)
    }
}
