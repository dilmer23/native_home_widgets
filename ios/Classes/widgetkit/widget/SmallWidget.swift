import SwiftUI
import WidgetKit

/// Shared data reader for all widget sizes.
///
/// Reads from shared UserDefaults (App Group) using the same key patterns
/// as the Android implementation.
@available(iOS 14.0, *)
struct WidgetDataValues {
    let title: String
    let value: String
    let description: String
    let detail: String

    static func read() -> WidgetDataValues {
        let store = WidgetDataStore()
        return WidgetDataValues(
            title: store.get(key: "title") as? String ?? "Widget",
            value: store.get(key: "value") as? String ?? "",
            description: store.get(key: "description") as? String ?? "",
            detail: store.get(key: "detail") as? String ?? ""
        )
    }
}

// ── Small Widget ─────────────────────────────────────────

@available(iOS 14.0, *)
struct SmallWidgetEntry: TimelineEntry {
    let date: Date
    let values: WidgetDataValues
}

@available(iOS 14.0, *)
struct SmallWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SmallWidgetEntry {
        SmallWidgetEntry(date: Date(), values: WidgetDataValues())
    }

    func getSnapshot(in context: Context, completion: @escaping (SmallWidgetEntry) -> Void) {
        completion(SmallWidgetEntry(date: Date(), values: WidgetDataValues.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SmallWidgetEntry>) -> Void) {
        let entry = SmallWidgetEntry(date: Date(), values: WidgetDataValues.read())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

@available(iOS 14.0, *)
struct SmallWidgetEntryView: View {
    var entry: SmallWidgetTimelineProvider.Entry

    var body: some View {
        let theme = WidgetThemeResolver.resolve()

        VStack(alignment: .leading, spacing: 4) {
            Text(entry.values.title)
                .font(.subheadline)
                .foregroundColor(WidgetThemeResolver.textSecondaryColor(for: theme))
            Text(entry.values.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(WidgetThemeResolver.textPrimaryColor(for: theme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(WidgetThemeResolver.backgroundColor(for: theme))
    }
}

@available(iOS 14.0, *)
struct SmallWidget: Widget {
    let kind = "native_home_widgets_small"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallWidgetTimelineProvider()) { entry in
            SmallWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Native Home Widget")
        .description("A small home screen widget managed from Flutter.")
        .supportedFamilies([.systemSmall])
    }
}

// ── Medium Widget ────────────────────────────────────────

@available(iOS 14.0, *)
struct MediumWidgetEntry: TimelineEntry {
    let date: Date
    let values: WidgetDataValues
}

@available(iOS 14.0, *)
struct MediumWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MediumWidgetEntry {
        MediumWidgetEntry(date: Date(), values: WidgetDataValues())
    }

    func getSnapshot(in context: Context, completion: @escaping (MediumWidgetEntry) -> Void) {
        completion(MediumWidgetEntry(date: Date(), values: WidgetDataValues.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MediumWidgetEntry>) -> Void) {
        let entry = MediumWidgetEntry(date: Date(), values: WidgetDataValues.read())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

@available(iOS 14.0, *)
struct MediumWidgetEntryView: View {
    var entry: MediumWidgetTimelineProvider.Entry

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.values.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(entry.values.value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                if !entry.values.description.isEmpty {
                    Text(entry.values.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

@available(iOS 14.0, *)
struct MediumWidget: Widget {
    let kind = "native_home_widgets_medium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediumWidgetTimelineProvider()) { entry in
            MediumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Native Home Widget")
        .description("A medium home screen widget managed from Flutter.")
        .supportedFamilies([.systemMedium])
    }
}

// ── Large Widget ─────────────────────────────────────────

@available(iOS 14.0, *)
struct LargeWidgetEntry: TimelineEntry {
    let date: Date
    let values: WidgetDataValues
}

@available(iOS 14.0, *)
struct LargeWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LargeWidgetEntry {
        LargeWidgetEntry(date: Date(), values: WidgetDataValues())
    }

    func getSnapshot(in context: Context, completion: @escaping (LargeWidgetEntry) -> Void) {
        completion(LargeWidgetEntry(date: Date(), values: WidgetDataValues.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LargeWidgetEntry>) -> Void) {
        let entry = LargeWidgetEntry(date: Date(), values: WidgetDataValues.read())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

@available(iOS 14.0, *)
struct LargeWidgetEntryView: View {
    var entry: LargeWidgetTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.values.title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(entry.values.value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            if !entry.values.description.isEmpty {
                Text(entry.values.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            if !entry.values.detail.isEmpty {
                Text(entry.values.detail)
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

@available(iOS 14.0, *)
struct LargeWidget: Widget {
    let kind = "native_home_widgets_large"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetTimelineProvider()) { entry in
            LargeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Native Home Widget")
        .description("A large home screen widget managed from Flutter.")
        .supportedFamilies([.systemLarge])
    }
}

/// WidgetBundle that aggregates all widgets provided by the plugin.
///
/// The developer must add this bundle to their Widget Extension target.
@available(iOS 14.0, *)
@main
struct NativeHomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallWidget()
        MediumWidget()
        LargeWidget()
        ProgressWidget()
        ClockWidget()
        BatteryWidget()
    }
}
