    //
    //  Shop.swift

    import SpriteKit

    /// Our model class to be used inside of our ShopScene:
    class Shop {
      
      weak private(set) var scene: ShopScene!     // The scene in which this shop will be called from.
      
      var player: Player { return scene.player }
      
      var availableCostumes: [Costume] = [Costume.list.red, Costume.list.blue]   // (The green shirt wont become available until the player has cleared 2 levels).
      
      // var soldCostumes: [Costume] = [Costume.defaultCostume] // Implement something with this if you want to exclude previously bought items from the store.

      func canSellCostume(_ costume: Costume) -> Bool {
        if player.coins < costume.price                { return false }
        else if player.hasCostume(costume)             { return false }
        else if player.costume == costume              { return false }
        else                                           { return true  }
      }
      
      /// Only call this after checking canBuyCostume(), or you likely will have errors:
      func sellCostume(_ costume: Costume) {
        player.loseCoins(costume.price)
        player.getCostume(costume)
        player.wearCostume(costume)
      }
      
      func newCostumeBecomesAvailable(_ costume: Costume) {
        if availableCostumes.contains(where: {$0.name == costume.name}) /*|| soldCostumes.contains(costume)*/ {
          fatalError("trying to add a costume that is already available (or sold!)")
        }
        else { availableCostumes.append(costume) }
      }
        
      init(shopScene: ShopScene) {
        self.scene = shopScene
      }
      
      deinit { print("shop: if you don't see this message when exiting shop then you have a retain cycle") }
    };
