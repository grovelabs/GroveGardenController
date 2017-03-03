struct Sensors {

  struct Air {
    let temperature: Double?
    let humidity: Double?
  }

  struct Water {
    let temperature: Double?
  }

  let air: Air
  let water: Water
}

extension Sensors.Air {
  init(json: [String: Any]) {
    let temperature = json["temp"] as? Double
    let humidity = json["humid"] as? Double

    self.temperature = temperature
    self.humidity = humidity
  }
}

extension Sensors.Water {
  init(json: [String: Any]) {
    guard
      let temperature = json["temp"] as? Double,
      temperature == abs(temperature) else {
        self.temperature = nil
        return
    }

    self.temperature = temperature
  }
}

extension Sensors {
  init(json: [String: Any]) throws {
    guard let airJSON = json["air"] as? [String: Any] else {
      throw SerializationError.missing("air")
    }
    guard let waterJSON = json["water"] as? [String: Any] else {
      throw SerializationError.missing("water")
    }

    self.air = Air(json: airJSON)
    self.water = Water(json: waterJSON)
  }
}
