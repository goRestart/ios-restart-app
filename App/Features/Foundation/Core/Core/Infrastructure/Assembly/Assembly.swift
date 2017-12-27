public final class Assembly {
  fileprivate static let shared = Assembly()
}

public var resolver: Assembly {
  return Assembly.shared
}
