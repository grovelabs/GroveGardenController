extension Grove {

  /**
    Resumes all three lights back to its scheduled settings
    */
  func lightSchedule() {
    device.callFunction("setLight", withArguments: ["schedule-a:resume"], completion: nil)
  }

  fileprivate func lightInterruption(settings: Light.Settings, duration: Int) {
    let durationString = String(format: "%04d", duration)
    let interruptionString = "temp-a:\(settings.toString()):\(durationString)"
    device.callFunction("setLight", withArguments: [interruptionString], completion: nil)
  }

  func lightInterruption(_ preset: Light.Settings.Presets) {
    lightInterruption(settings: preset.settings, duration: preset.duration)
  }

}
