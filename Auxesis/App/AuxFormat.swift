import AuxCanvasCore
import Foundation

/// Role: every number on screen goes through NumberFormatter. Day edges use Calendar.startOfDay.
enum AuxFormat {
    private static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    static func integer(_ value: Int) -> String {
        integerFormatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private static let paceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    static func minutes(_ seconds: Int) -> String {
        let minutes = max(0, seconds / 60)
        let number = integer(minutes)
        if minutes == 1 {
            return "\(number) min"
        }
        return "\(number) min"
    }

    static func pace(_ millis: Int) -> String {
        let seconds = Double(max(0, millis)) / 1000
        let number = paceFormatter.string(from: NSNumber(value: seconds)) ?? "0.0"
        return "\(number) s"
    }

    static func ringsOutOfSeven(_ count: Int) -> String {
        "\(integer(count)) of \(integer(7))"
    }

    static func day(_ dayKey: DayKey, calendar: Calendar = .current) -> String {
        guard let date = dayKey.startDate(calendar: calendar) else {
            return integer(Int(dayKey.raw))
        }
        return dayFormatter.string(from: date)
    }

    static func month(_ dayKey: DayKey, calendar: Calendar = .current) -> String {
        guard let date = dayKey.startDate(calendar: calendar) else {
            return integer(Int(dayKey.raw))
        }
        return monthFormatter.string(from: date)
    }

    static func dayOfMonth(_ dayKey: DayKey, calendar: Calendar = .current) -> String {
        guard let date = dayKey.startDate(calendar: calendar) else {
            return integer(Int(dayKey.raw % 100))
        }
        return integer(calendar.component(.day, from: date))
    }
}
