enum SerializationError: Swift.Error {
  case missing(String)
  case invalid(String, Any)
}

enum ParticleError: Swift.Error {
  case noDevice
}
