import SwiftUI
import WidgetKit

// ── Progress Widget ─────────────────────────────────────

@available(iOS 14.0, *)
struct ProgressWidgetEntry: TimelineEntry {
    let date: Date
    let values: WidgetDataValues
    let progress: Double
}

@available(iOS 14.0, *)
struct ProgressWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressWidgetEntry {
        ProgressWidgetEntry(date: Date(), values: WidgetDataValues(), progress: 0.5)
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressWidgetEntry) -> Void) {
        let values = WidgetDataValues.read()
        let progress = (values.value as? NSString)?.doubleValue ?? 0.0
        completion(ProgressWidgetEntry(date: Date(), values: values, progress: progress / 100.0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressWidgetEntry>) -> Void) {
        let values = WidgetDataValues.read()
        let progress = (values.value as? NSString)?.doubleValue ?? 0.0
        let entry = ProgressWidgetEntry(date: Date(), values: values, progress: progress / 100.0)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

@available(iOS 14.0, *)
struct ProgressWidgetEntryView: View {
    var entry: ProgressWidgetTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.values.title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * CGFloat(entry.progress), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(entry.progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                if !entry.values.description.isEmpty {
                    Text(entry.values.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
    }
}

@available(iOS 14.0, *)
struct ProgressWidget: Widget {
    let kind = "native_home_widgets_progress"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressWidgetTimelineProvider()) { entry in
            ProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Progress Widget")
        .description("A progress indicator widget managed from Flutter.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ── Clock Widget ─────────────────────────────────────────

@available(iOS 14.0, *)
struct ClockWidgetEntry: TimelineEntry {
    let date: Date
    let timeText: String
    let dateText: String
}

@available(iOS 14.0, *)
struct ClockWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockWidgetEntry {
        ClockWidgetEntry(date: Date(), timeText: "12:00", dateText: "Mon, Jan 1")
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockWidgetEntry) -> Void) {
        completion(createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWidgetEntry>) -> Void) {
        let entry = createEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func createEntry() -> ClockWidgetEntry {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        return ClockWidgetEntry(
            date: now,
            timeText: timeFormatter.string(from: now),
            dateText: dateFormatter.string(from: now)
        )
    }
}

@available(iOS 14.0, *)
struct ClockWidgetEntryView: View {
    var entry: ClockWidgetTimelineProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.timeText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(entry.dateText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14.0, *)
struct ClockWidget: Widget {
    let kind = "native_home_widgets_clock"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockWidgetTimelineProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Clock Widget")
        .description("A clock and date widget.")
        .supportedFamilies([.systemSmall])
    }
}

// ── Battery Widget ───────────────────────────────────────

@available(iOS 14.0, *)
struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let level: Int
    let isCharging: Bool
}

@available(iOS 14.0, *)
struct BatteryWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(date: Date(), level: 80, isCharging: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> Void) {
        completion(readBattery())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> Void) {
        let entry = readBattery()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readBattery() -> BatteryWidgetEntry {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
        return BatteryWidgetEntry(date: Date(), level: level > 0 ? level : 0, isCharging: isCharging)
    }
}

@available(iOS 14.0, *)
struct BatteryWidgetEntryView: View {
    var entry: BatteryWidgetTimelineProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text("\(entry.level)%")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(entry.level > 20 ? .green : .red)

            if entry.isCharging {
                Text("Charging")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14.0, *)
struct BatteryWidget: Widget {
    let kind = "native_home_widgets_battery"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryWidgetTimelineProvider()) { entry in
            BatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery Widget")
        .description("A battery status widget.")
        .supportedFamilies([.systemSmall])
    }
}
