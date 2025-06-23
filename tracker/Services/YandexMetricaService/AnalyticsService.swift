import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "322d109b-550a-4a77-813c-ee65e320327a") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func logMainScreenEvent(event: TrackerEvent, item: TrackerItem? = nil) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": "Main"
        ]
        if let item = item {
            params["item"] = item.rawValue
        }
        AnalyticsService.report(event: event.rawValue, params: params)
    }
}

enum TrackerEvent: String {
    case open
    case close
    case click
}

enum TrackerItem: String {
    case addTtrack
    case track
    case filter
    case edit
    case delete
}
