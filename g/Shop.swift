//
//  Shop.swift

import SpriteKit


/// Our model class to be used inside of our ShopScene:
class Shop {
  
  weak private(set) var scene: ShopScene!     // The scene in which this shop will be called from
  
  var player: Player { return scene.player }
  
  var availableCostumes: [Costume] = [Costume.list.red, Costume.list.blue]   // (The green shirt wont become available until the player has cleared 2 levels)
  
  var soldCostumes: [Costume] = [Costume.defaultCostume]
  
  func canBuyCostume(_ costume: Costume) -> Bool {
    if player.coins < costume.price        { return false }
    else if soldCostumes.contains(costume) { return false }
    else if player.costume == costume      { return false }
    else                                   { return true  }
  }
  
  func wearCostume(_ costume: Costume) {
    guard soldCostumes.contains(costume) else { fatalError("trying to wear a costume you don't own") }
    player.costume = costume
    player.texture = costume.texture
  }
  
  func buyCostume(_ costume: Costume) {    // Only call this after checking canBuyCostume(), or you may have errors
    player.coins -= costume.price
    soldCostumes.append(costume)
    wearCostume(costume)
  }
  
  func newCostumeBecomesAvailable(_ costume: Costume) {
    
    if availableCostumes.contains(costume) || soldCostumes.contains(costume) {
      fatalError("trying to add a costume that is already available or sold!")
    }
    else { availableCostumes.append(costume) }
  }
  
  func exitShop() { scene.view!.presentScene(scene.previousGameScene) }
  
  init(shopScene: ShopScene) { self.scene = shopScene }
  
  deinit { print("shop: if you don't see this message when exiting shop then you have a retain cycle") }
};
