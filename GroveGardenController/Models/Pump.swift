struct Pump {

  struct Schedule {
    enum Presets {
      static let off = Pump.Schedule(on: 0, off: 60 * 60)
      static let less = Pump.Schedule(on: 5 * 60, off: 55 * 60)
      static let normal = Pump.Schedule(on: 15 * 60, off: 45 * 60)
      static let more = Pump.Schedule(on: 30 * 60, off: 30 * 60)
      static let on = Pump.Schedule(on: 60 * 60, off: 0)
    }
    let on: TimeInterval
    let off: TimeInterval
  }

  struct Interuption {
    let indefinite: Bool
    let duration: TimeInterval
    let secondsLeft: TimeInterval
  }

  let on: Bool
  let schedule: Pump.Schedule
  let interruption: Pump.Interuption?
}

extension Pump.Schedule {
  init(json: [String: Any]) throws {
    guard let on = json["onTimeMins"] as? Int else {
      throw SerializationError.missing("onTimeMins")
    }
    guard let off = json["offTimeMins"] as? Int else {
      throw SerializationError.missing("offTimeMins")
    }

    self.on = TimeInterval(on * 60)
    self.off = TimeInterval(off * 60)
  }
}

extension Pump.Schedule: Equatable {}
func ==(rhs: Pump.Schedule, lhs: Pump.Schedule) -> Bool {
  return (rhs.on == lhs.on) && (rhs.off == lhs.off)
}

extension Pump.Interuption {
  init(json: [String: Any]) throws {
    guard let indefinite = json["indef"] as? Bool else {
      throw SerializationError.missing("indef")
    }
    guard let duration = json["dur"] as? Int else {
      throw SerializationError.missing("dur")
    }
    guard let secondsLeft = json["secsLeft"] as? TimeInterval else {
      throw SerializationError.missing("secsLeft")
    }

    self.indefinite = indefinite
    self.duration = TimeInterval(duration * 60)
    self.secondsLeft = secondsLeft
  }
}

extension Pump {
  init(json: [String: Any]) throws {
    guard let on = json["pumpOn"] as? Bool else {
      throw SerializationError.missing("pumpOn")
    }
    guard let scheduleJSON = json["sched"] as? [String: Any] else {
      throw SerializationError.missing("sched")
    }

    guard let mode = json["mode"] as? String else {
      throw SerializationError.missing("mode")
    }

    switch mode {
    case "SCHEDULE_HOUR_ALIGNED", "SCHEDULE_ARBITRARY_DUTY_CYCLE":
      self.interruption = nil

    case "CONSTANT_ON", "INTERRUPTED_CONSTANT_STATE", "DISABLED":
      guard let interruptionJSON = json["inter"] as? [String: Any] else {
        throw SerializationError.missing("inter")
      }
      self.interruption = try Pump.Interuption(json: interruptionJSON)

    default:
      throw SerializationError.invalid("mode", mode)
    }

    self.on = on
    self.schedule = try Pump.Schedule(json: scheduleJSON)
  }
}

