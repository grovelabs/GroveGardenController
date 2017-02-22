struct Fan {

  enum Speed: String {
    case off = "OFF"
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
  }

  struct Schedule {
    let speed: Fan.Speed
    let breeze: Bool
  }

  struct Interruption {
    let speed: Fan.Speed
    let breeze: Bool
    let indefinite: Bool
    let duration: Int
    let secondsLeft: Int
  }

  let intensity: Double
  let schedule: Fan.Schedule
  let interruption: Fan.Interruption?
}

extension Fan.Schedule {
  init(json: [String: Any]) throws {
    guard let speedString = json["speed"] as? String else {
      throw SerializationError.missing("speed")
    }
    guard let speed = Fan.Speed(rawValue: speedString) else {
      throw SerializationError.invalid("speed", speedString)
    }
    guard let breeze = json["breezeEnabled"] as? Bool else {
      throw SerializationError.missing("breezeEnabled")
    }

    self.speed = speed
    self.breeze = breeze
  }
}

extension Fan.Interruption {
  init(json: [String: Any]) throws {
    guard let speedString = json["speed"] as? String else {
      throw SerializationError.missing("speed")
    }
    guard let speed = Fan.Speed(rawValue: speedString) else {
      throw SerializationError.invalid("speed", speedString)
    }
    guard let breeze = json["breezeEnabled"] as? Bool else {
      throw SerializationError.missing("breezeEnabled")
    }
    guard let indefinite = json["indef"] as? Bool else {
      throw SerializationError.missing("indef")
    }
    guard let duration = json["dur"] as? Int else {
      throw SerializationError.missing("dur")
    }
    guard let secondsLeft = json["secsLeft"] as? Int else {
      throw SerializationError.missing("secsLeft")
    }

    self.speed = speed
    self.breeze = breeze
    self.indefinite = indefinite
    self.duration = duration
    self.secondsLeft = secondsLeft
  }
}

extension Fan {
  init(json: [String: Any]) throws {
    guard let intensity = json["currentIntensity"] as? Double else {
      throw SerializationError.missing("currentIntensity")
    }
    guard let scheduleJSON = json["sched"] as? [String: Any] else {
      throw SerializationError.missing("sched")
    }
    guard let mode = json["mode"] as? String else {
      throw SerializationError.missing("mode")
    }

    switch mode {
    case "SCHED_SS":
      self.interruption = nil

    case "INTER_SS":
      guard let interruptionJSON = json["inter"] as? [String: Any] else {
        throw SerializationError.missing("inter")
      }
      self.interruption = try Fan.Interruption(json: interruptionJSON)

    default:
      throw SerializationError.invalid("mode", mode)
    }

    self.intensity = intensity
    self.schedule = try Fan.Schedule(json: scheduleJSON)
  }
}
