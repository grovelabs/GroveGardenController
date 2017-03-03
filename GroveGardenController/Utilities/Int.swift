extension Int {
  func printableFahrenheit() -> String {
    return Double(self).printableFahrenheit()
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
