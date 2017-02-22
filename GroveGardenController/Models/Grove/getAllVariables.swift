extension Grove {

  /**
   Calls each variable from the Grove until it has all the data required to build a Grove.

   Completion closure will contain a Grove object, or nil if there was an error.
   */
  static func getAllVariables(device: SparkDevice, completion: @escaping (Grove?) -> Void) {

    let dispatchVariables = DispatchGroup()

    var _sensors: Sensors? = nil
    var _light0: Light? = nil
    var _light1: Light? = nil
    var _light2: Light? = nil
    var _pump: Pump? = nil
    var _fan: Fan? = nil

    dispatchVariables.enter()
    device.getVariable("sensors") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let sensors = try? Sensors(json: json) else {
          return dispatchVariables.leave()
      }
      _sensors = sensors
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light0 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light1") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light1 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light2") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light2 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("pump0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _pump = try? Pump(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("fan0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _fan = try? Fan(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.notify(queue: .main) {
      guard
        let name = device.name,
        let sensors = _sensors,
        let light0 = _light0,
        let light1 = _light1,
        let light2 = _light2,
        let pump = _pump,
        let fan = _fan else {
          return completion(nil)
      }
      let grove = Grove(serialNumber: name,
                        connected: device.connected,
                        sensors: sensors,
                        light0: light0,
                        light1: light1,
                        light2: light2,
                        pump: pump,
                        fan: fan)
      completion(grove)
    }
  }
}