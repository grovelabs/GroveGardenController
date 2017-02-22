
/**
 Sample JSON:
 ```
 {
   "pumpOn":true,
   "mode":"SCHEDULE_HOUR_ALIGNED",
   "why":"AUTO",
   "sched": {
     "onTimeMins":15,
     "offTimeMins":45,
     "aribitraryModeSecsLeft":0
   },
   "inter":{
     "indef":false,
     "dur":720,
     "secsLeft":0
   },
   "power":{
     "alarm":0,
     "value":0.00
   }
 }
 ```
 */
struct Pump {

  struct Schedule {
    let on: Int
    let off: Int
  }

  struct Interuption {
    let indefinite: Bool
    let duration: Int
    let secondsLeft: Int
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

    self.on = on
    self.off = off
  }
}

extension Pump.Interuption {
  init(json: [String: Any]) throws {
    guard let indefinite = json["indef"] as? Bool else {
      throw SerializationError.missing("indef")
    }
    guard let duration = json["dur"] as? Int else {
      throw SerializationError.missing("dur")
    }
    guard let secondsLeft = json["secsLeft"] as? Int else {
      throw SerializationError.missing("secsLeft")
    }

    self.indefinite = indefinite
    self.duration = duration
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

