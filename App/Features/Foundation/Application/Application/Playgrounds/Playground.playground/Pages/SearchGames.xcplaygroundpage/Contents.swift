import Application
import Domain
import PlaygroundSupport

/*:
 ## Search games
 */

async { fulfill in
  
  let searchGames = SearchGames()
  searchGames.execute(with: "Mario").subscribe(onSuccess: { games in
    print("Results = \(games)")
    fulfill()
  }, onError: { error in
    print("Error: \(error)")
    fulfill()
  })
}
//: [Previous](@previous)
