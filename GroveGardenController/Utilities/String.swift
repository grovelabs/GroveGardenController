extension String {
  func parseJSON() throws -> [String: Any] {
    guard
      let data = self.data(using: String.Encoding.utf8),
      let jsonObj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)),
      let json = jsonObj as? [String: Any] else {
        throw SerializationError.invalid("JSON", self)
    }
    return json
  }
}
