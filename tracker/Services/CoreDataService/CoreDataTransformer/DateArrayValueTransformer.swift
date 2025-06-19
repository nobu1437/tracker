import Foundation

@objc
final class DateArrayValueTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let dates = value as? [Date] else { return nil }
        return try? JSONEncoder().encode(dates)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([Date].self, from: data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DateArrayValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DateArrayValueTransformer.self))
        )
    }
}
