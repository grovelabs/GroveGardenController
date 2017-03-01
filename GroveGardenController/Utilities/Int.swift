extension Int {
  func normalizeTo255() -> Int {
    switch self {
    case Int.min..<1: return 0
    case 255..<Int.max: return 255
    default: return self
    }
  }

  func printableFahrenheit() -> String {
    return Double(self).printableFahrenheit()
  }

  func normalizeSeconds() -> Int {
    switch self {
    case Int.min..<1: return 0
    case 86399..<Int.max: return 86399
    default: return self
    }
  }

  func secondsToPrintableTime() -> String {
    let minutes = self.normalizeSeconds() / 60

    let hour = minutes / 60
    let minute = minutes % 60
    let anteMeridiem = (hour >= 12) ? "PM" : "AM"
    let printableHour: Int = {
      switch hour {
      case 0: return 12
      case 13..<24: return hour - 12
      default: return hour
      }
    }()
    return "\(printableHour):\(String(format: "%02d", minute))\(anteMeridiem)"
  }

  func toSliderValue() -> Float {
    return Float(self) / 100
  }
}

extension Double {
  func printableFahrenheit() -> String {
    let fahrenheit = (self * 1.8) + 32
    return String(format: "%.02f ℉", fahrenheit)
  }
}
