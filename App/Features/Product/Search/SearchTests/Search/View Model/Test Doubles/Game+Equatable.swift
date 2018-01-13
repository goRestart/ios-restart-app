import Domain

extension Game: Equatable {
  public static func ==(lhs: Game, rhs: Game) -> Bool {
    return lhs.id == rhs.id
  }
}
