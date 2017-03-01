struct Light {

  enum Location {
    case garden, seedling, aquarium
  }

  struct Settings {

    enum Presets {
      case off, harvest, movie, photo

      var settings: Light.Settings {
        switch self {
        case .off: return Light.Settings(intensity: 0, colorTemp: 100)
        case .harvest: return Light.Settings(intensity: 10, colorTemp: 100)
        case .movie: return Light.Settings(intensity: 1, colorTemp: 0)
        case .photo: return Light.Settings(intensity: 5, colorTemp: 50)
        }
      }

      var duration: Int {
        switch self {
        case .off: return 30
        case .harvest: return 30
        case .movie: return 120
        case .photo: return 10
        }
      }
    }

    let intensity: Int
    let colorTemp: Int

    func toString() -> String {
      let intensityString = String(format: "%03d", intensity)
      let colorString = String(format: "%03d", colorTemp)
      return intensityString + ":" + colorString
    }
  }

  struct Schedule {
    let day: Light.Settings
    let night: Light.Settings
    let sunriseBegins: Int
    let dayBegins: Int
    let sunsetBegins: Int
    let nightBegins: Int

    func printableSchedule() -> String {
      return "\(sunriseBegins.secondsToPrintableTime()) - \(nightBegins.secondsToPrintableTime())"
    }

    func changeSettings(intensity: Int? = nil, color: Int? = nil) -> Light.Schedule {
      let newDay = Light.Settings(intensity: intensity ?? day.intensity,
                                  colorTemp: color ?? day.colorTemp)

      return Light.Schedule(day: newDay,
                            night: night,
                            sunriseBegins: sunriseBegins,
                            dayBegins: dayBegins,
                            sunsetBegins: sunsetBegins,
                            nightBegins: nightBegins)
    }
  }

  struct Interuption {
    let setting: Light.Settings
    let duration: Int
    let secondsLeft: Int
  }

  let schedule: Schedule
  let interruption: Interuption?
}

extension Light.Settings {
  init(json: [Int]) throws {
    self.intensity = json[0]
    self.colorTemp = json[1]
  }
}

extension Light.Settings: Equatable {}
func ==(rhs: Light.Settings, lhs: Light.Settings) -> Bool {
  return (rhs.intensity == lhs.intensity) && (rhs.colorTemp == lhs.colorTemp)
}

extension Light.Schedule {
  init(json: [String: Any]) throws {
    guard let dayJSON = json["day"] as? [Int] else {
      throw SerializationError.missing("day")
    }
    guard let nightJSON = json["night"] as? [Int] else {
      throw SerializationError.missing("night")
    }
    guard let times = json["times"] as? [Int] else {
      throw SerializationError.missing("times")
    }

    self.day = try Light.Settings(json: dayJSON)
    self.night = try Light.Settings(json: nightJSON)
    self.sunriseBegins = times[0]
    self.dayBegins = times[1]
    self.sunsetBegins = times[2]
    self.nightBegins = times[3]
  }
}

extension Light.Interuption {
  init(json: [String: Any]) throws {
    guard let settingJSON = json["ls"] as? [Int] else {
      throw SerializationError.missing("ls")
    }
    guard let duration = json["dur"] as? Int else {
      throw SerializationError.missing("dur")
    }
    guard let secondsLeft = json["secsLeft"] as? Int else {
      throw SerializationError.missing("secsLeft")
    }

    self.setting = try Light.Settings(json: settingJSON)
    self.duration = duration
    self.secondsLeft = secondsLeft
  }
}

extension Light {
  init(json: [String: Any]) throws {
    guard let scheduleJSON = json["sched"] as? [String: Any] else {
      throw SerializationError.missing("sched")
    }

    guard let mode = json["mode"] as? String else {
      throw SerializationError.missing("mode")
    }

    switch mode {
    case "SCHED_SS", "FADEtoSCHED":
      self.interruption = nil

    case "INTER_SS", "FADEtoINTER", "WAITbfINTER":
      guard let interruptionJSON = json["inter"] as? [String: Any] else {
        throw SerializationError.missing("inter")
      }
      self.interruption = try Light.Interuption(json: interruptionJSON)

    default:
      throw SerializationError.invalid("mode", mode)
    }

    self.schedule = try Light.Schedule(json: scheduleJSON)
  }
}
