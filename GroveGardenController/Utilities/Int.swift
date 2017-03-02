extension Int {
  func printableFahrenheit() -> String {
    return Double(self).printableFahrenheit()
  }

  func toSliderValue() -> Float {
    return Float(self) / 100
  }
}

// TODO: Replace `Minutes` and `Seconds` with TimeInterval
public typealias Minutes = Int
public typealias Seconds = Int

extension Seconds {
  func toDate() -> Date? {
    let cal = Calendar.current
    let components = DateComponents(second: self)
    return cal.date(from: components)
  }

  func toPrintableTime() -> String? {
    guard let date = self.toDate() else { return nil }
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }

  func correctToDayLength() -> Seconds {
    let secondsInADay = 86400
    let pos = abs(self)
    if (pos >= secondsInADay) {
      let correction = pos - secondsInADay
      return correction.correctToDayLength()
    }
    return pos
  }
}

extension Double {
  func printableFahrenheit() -> String {
    let fahrenheit = (self * 1.8) + 32
    return String(format: "%.02f ℉", fahrenheit)
  }
}

extension Date {
  static func timeBetween(_ firstDate: Date,
                          _ secondDate: Date) -> TimeInterval {
    return abs(secondDate.timeIntervalSince(firstDate))
  }

  func seconds() -> Seconds {
    let cal = Calendar.current
    let hours = cal.component(.hour, from: self)
    let minutes = cal.component(.minute, from: self)
    let seconds = cal.component(.second, from: self)
    return (hours * 60 * 60) + (minutes * 60) + seconds
  }
}

extension TimeInterval {
  func hoursAndMinutes() -> (hours: Int, minutes: Int) {
    let totalMinutes = Int(self / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return (hours, minutes)
  }
}
