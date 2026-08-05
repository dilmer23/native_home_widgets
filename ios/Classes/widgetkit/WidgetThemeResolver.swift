import SwiftUI

/// Resolves widget theme configuration from stored data on iOS.
///
/// Reads theme preferences from shared UserDefaults (App Group) and
/// provides colors appropriate for light/dark mode.
@available(iOS 14.0, *)
struct WidgetThemeResolver {

    struct WidgetTheme {
        let isDark: Bool
        let useMaterialYou: Bool
        let isRtl: Bool
    }

    static func resolve() -> WidgetTheme {
        let store = WidgetDataStore()
        let brightness = store.get(key: "_theme_brightness") as? String
        let materialYou = store.get(key: "_theme_material_you") as? String
        let direction = store.get(key: "_direction") as? String

        return WidgetTheme(
            isDark: brightness == "dark",
            useMaterialYou: materialYou == "true",
            isRtl: direction == "rtl"
        )
    }

    static func backgroundColor(for theme: WidgetTheme) -> Color {
        theme.isDark ? Color(red: 0.11, green: 0.11, blue: 0.12) : .white
    }

    static func textPrimaryColor(for theme: WidgetTheme) -> Color {
        theme.isDark ? Color(red: 0.90, green: 0.88, blue: 0.90) : .primary
    }

    static func textSecondaryColor(for theme: WidgetTheme) -> Color {
        theme.isDark ? Color(red: 0.79, green: 0.77, blue: 0.81) : .secondary
    }
}
