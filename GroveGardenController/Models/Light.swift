struct Light {

  struct Setting {
    let intensity: Double
    let colorTemp: Double
  }

  struct Schedule {
    let day: Light.Setting
    let night: Light.Setting
    let sunriseBegins: Int
    let dayBegins: Int
    let sunsetBegins: Int
    let nightBegins: Int
  }

  struct Interuption {
    let setting: Light.Setting
    let duration: Int
    let secondsLeft: Int
  }

  let schedule: Schedule
  let interruption: Interuption?
}

extension Light.Setting {
  init(json: [Double]) throws {
    self.intensity = json[0]
    self.colorTemp = json[1]
  }
}

extension Light.Schedule {
  init(json: [String: Any]) throws {
    guard let dayJSON = json["day"] as? [Double] else {
      throw SerializationError.missing("day")
    }
    guard let nightJSON = json["night"] as? [Double] else {
      throw SerializationError.missing("night")
    }
    guard let times = json["times"] as? [Int] else {
      throw SerializationError.missing("times")
    }

    self.day = try Light.Setting(json: dayJSON)
    self.night = try Light.Setting(json: nightJSON)
    self.sunriseBegins = times[0]
    self.dayBegins = times[1]
    self.sunsetBegins = times[2]
    self.nightBegins = times[3]
  }
}

extension Light.Interuption {
  init(json: [String: Any]) throws {
    guard let settingJSON = json["ls"] as? [Double] else {
      throw SerializationError.missing("ls")
    }
    guard let duration = json["dur"] as? Int else {
      throw SerializationError.missing("dur")
    }
    guard let secondsLeft = json["secsLeft"] as? Int else {
      throw SerializationError.missing("secsLeft")
    }

    self.setting = try Light.Setting(json: settingJSON)
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
