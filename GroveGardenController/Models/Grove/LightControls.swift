extension Grove {

  /**
    Resumes all three lights back to its scheduled settings
    */
  func lightSchedule() {
    device.callFunction("setLight", withArguments: ["schedule-a:resume"], completion: nil)
  }

  func lightSchedule(_ location: Light.Location, schedule: Light.Schedule) {
    let whichLight: String = {
      switch location {
      case .garden: return "0"
      case .seedling: return "1"
      case .aquarium: return "2"
      }
    }()

    let scheduleString = "schedule-"
      + whichLight
      + String(format: ":%04d", Int(schedule.sunriseBegins / 60))
      + ":030"
      + String(format: ":%04d", Int(schedule.sunsetBegins / 60))
      + ":030"
      + ":" + schedule.day.toString()
      + ":" + schedule.night.toString()
      + ":2"

    device.callFunction("setLight", withArguments: [scheduleString], completion: nil)
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
