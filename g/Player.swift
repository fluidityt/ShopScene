//
//  Player.swift

    import SpriteKit

    final class Player: SKSpriteNode {
      
      var coins = 0
      var costume: Costume
      var levelsCompleted = 0
      
      var ownedCostumes: [Costume] = [Costume.list.gray]      // FIXME: This should be a Set, but too lazy to do Hashable.
      
      init(costume: Costume) {
        self.costume = costume
        super.init(texture: costume.texture, color: .clear, size: costume.texture.size())
      }
      
      func getCoins(_ amount: Int) {
        guard let scene = self.scene as? GameScene else {     // This is very specific code just for this example.
          fatalError("only call this func after scene has been set up")
        }
        
        coins += amount
        scene.coinLabel.text = "Coins: \(coins)"
      }
      
      func loseCoins(_ amount: Int) {
        guard let scene = self.scene as? GameScene else {     // This is very specific code just for this example.
          fatalError("only call this func after scene has been set up")
        }
        
        coins -= amount
        scene.coinLabel.text = "Coins: \(coins)"
      }
      
      func hasCostume(_ costume: Costume) -> Bool {
        if ownedCostumes.contains(where: {$0.name == costume.name}) { return true }
        else { return false }
      }
      
      func getCostume(_ costume: Costume) {
        if hasCostume(costume) { fatalError("trying to get costume already owned") }
        else { ownedCostumes.append(costume) }
      }
      
      func wearCostume(_ costume: Costume) {
        guard hasCostume(costume) else { fatalError("trying to wear a costume you don't own") }
        self.costume = costume
        self.texture = costume.texture
      }
      
      required init?(coder aDecoder: NSCoder) { fatalError() }
    };
