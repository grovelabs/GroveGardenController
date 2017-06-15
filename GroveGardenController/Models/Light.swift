import Foundation

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
        case .harvest: return Light.Settings(intensity: 15, colorTemp: 75)
        case .movie: return Light.Settings(intensity: 7, colorTemp: 0)
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
    let sunriseBegins: TimeInterval
    let dayBegins: TimeInterval
    let sunsetBegins: TimeInterval
    let nightBegins: TimeInterval

    func dayLength() -> TimeInterval {
      switch self.nightBegins.toDate().timeIntervalSince(self.sunriseBegins.toDate()) {
      case let diff where diff != abs(diff):
        return diff + TimeInterval.day
      case let diff:
        return diff
      }
    }

    func changeSettings(intensity newIntensity: Int? = nil,
                        color newColor: Int? = nil) -> Light.Schedule {

      let newDay = Light.Settings(intensity: newIntensity ?? self.day.intensity,
                                  colorTemp: newColor ?? self.day.colorTemp)

      return Light.Schedule(day: newDay,
                            night: night,
                            sunriseBegins: sunriseBegins,
                            dayBegins: dayBegins,
                            sunsetBegins: sunsetBegins,
                            nightBegins: nightBegins)
    }

    /**
     Create a new light schedule with a different day length
     
     Can throw an error if the dayLength is not an hour or longer
     */
    func changeSettings(dayLength newDayLength: TimeInterval) throws -> Light.Schedule {
      if (newDayLength >= TimeInterval.day) {
        throw LightScheduleError.dayLengthTooLong
      }

      let newNight = (self.sunriseBegins + newDayLength).dayLengthBounds()
      let newSunset = (newNight - TimeInterval.halfAnHour).dayLengthBounds()

      let newSchedule = Light.Schedule(day: self.day,
                                       night: self.night,
                                       sunriseBegins: self.sunriseBegins,
                                       dayBegins: self.dayBegins,
                                       sunsetBegins: newSunset,
                                       nightBegins: newNight)

      if (newSchedule.dayLength() < TimeInterval.hour) {
        throw LightScheduleError.dayLengthNotLongEnough
      }
      return newSchedule
    }

    /**
     Create a new light schedule with a different sunrise.
     The new schedule moves the schedule to keep the day length the same.
     */
    func changeSettings(sunriseBegins newSunriseBegins: TimeInterval) -> Light.Schedule {
      let newDayBegins = (newSunriseBegins + TimeInterval.halfAnHour).dayLengthBounds()
      let newNightBegins = (newSunriseBegins + self.dayLength()).dayLengthBounds()
      let newSunsetBegins = (newNightBegins - TimeInterval.halfAnHour).dayLengthBounds()

      return Light.Schedule(day: self.day,
                            night: self.night,
                            sunriseBegins: newSunriseBegins,
                            dayBegins: newDayBegins,
                            sunsetBegins: newSunsetBegins,
                            nightBegins: newNightBegins)
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
    guard let times = json["times"] as? [TimeInterval] else {
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
