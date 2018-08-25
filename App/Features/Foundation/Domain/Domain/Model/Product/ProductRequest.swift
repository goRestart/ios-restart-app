import Foundation

public struct ProductRequest {
  public let gameId: Identifier<Game>
  public let gameConsoleId: Identifier<GameConsole>
  public let description: String
  public let imageIds: [Identifier<Image>]
  public let price: Product.Price

  public init(gameId: Identifier<Game>,
              gameConsoleId: Identifier<GameConsole>,
              description: String,
              imageIds: [Identifier<Image>],
              price: Product.Price)
  {
    self.gameId = gameId
    self.gameConsoleId = gameConsoleId
    self.description = description
    self.imageIds = imageIds
    self.price = price
  }
}
