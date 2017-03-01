extension Int {
  func normalizeTo255() -> Int {
    switch self {
    case Int.min..<1: return 0
    case 255..<Int.max: return 255
    default: return self
    }
  }

  func toFahrenheit() -> String {
    return Double(self).toFahrenheit()
  }
}

extension Double {
  func toFahrenheit() -> String {
    let fahrenheit = (self * 1.8) + 32
    return String(format: "%.02f ℉", fahrenheit)
  }
}
