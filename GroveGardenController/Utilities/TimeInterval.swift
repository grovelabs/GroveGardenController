import Foundation

extension TimeInterval {
  static let halfAnHour: TimeInterval = 30 * 60
  static let hour: TimeInterval = 60 * 60
  static let day: TimeInterval = 24 * 60 * 60

  func parts() -> (hours: Int, minutes: Int, seconds: Int, ms: Int) {
    let ti = NSInteger(self)
    let remainder = self.truncatingRemainder(dividingBy: 1)
    let ms = Int(remainder * 1000)
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    return (hours, minutes, seconds, ms)
  }

  func toDate() -> Date {
    let middnight = Calendar.current.startOfDay(for: Date())
    return Date(timeInterval: self, since: middnight)
  }

  func printable() -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: self.toDate())
  }

  func dayLengthBounds() -> TimeInterval {
    let pos = abs(self)
    if (pos >= TimeInterval.day) {
      let correction = pos - TimeInterval.day
      return correction.dayLengthBounds()
    }
    return pos
  }
}

extension Date {
  func toSeconds() -> TimeInterval {
    let middnight = Calendar.current.startOfDay(for: Date())
    return self.timeIntervalSince(middnight)
  }
}
