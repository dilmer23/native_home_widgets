import Foundation
import WidgetKit

/// Controls WidgetKit widget lifecycle — timeline reloads and invalidation.
enum WidgetController {

    /// Reloads timelines for all widgets provided by this extension.
    static func reloadAllTimelines() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Reloads the timeline for a specific widget kind.
    static func reloadTimelines(ofKind kind: String) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
    }
}
