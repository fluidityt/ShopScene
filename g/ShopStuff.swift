//
//  ShopStuff.swift

import SpriteKit


/// Our model class to be used inside of our ShopScene:
class Shop {
  
  // The scene in which this shop will be called from:
  weak private(set) var scene: ShopScene!
  
  var player: Player { return scene.player }
  
  // Add each costume you want to be available for purchase to the player at this time:
  // (The green shirt wont become available until the player has cleared 2 levels)
  var availableCostumes: [Costume] = [Costume.red, Costume.blue]
  
  // Keeps track of sold costumes:
  var soldCostumes: [Costume] = [Costume.gray]                // Gray shirt is our default shirt
  
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
  
  // Only call this after checking canBuyCostume(), or you may have errors.
  func buyCostume(_ costume: Costume) {
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

/// The scene in which we can interact with our shop and player:
class ShopScene: SKScene {
  
  // Properties:
  private lazy var shop: Shop = Shop(shopScene: self)
  
  let previousGameScene: GameScene
  
  var player: Player { return self.previousGameScene.player }
  
  // Changes as you click around the screen
  private var selectedNode = SKSpriteNode()
  
  // The things you click to interact with / view the shop:
  private let
  buyNode = SKLabelNode(),
  costumeNodes = [SKSpriteNode](),
  playerAvatar = SKSpriteNode()
  
  private func setUpNodes() {
    func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
    
    buyNode.text = "Buy Costume"
  }
  
  // Touches:
  override func mouseDown(with event: NSEvent) {
    
    shop.exitShop()
  }
  
  // Init:
  init(previousGameScene: GameScene) {
    self.previousGameScene = previousGameScene
    super.init(size: previousGameScene.size)
    print("new scene")
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
  
  deinit { print("shopscene: if you don't see this message when exiting shop then you have a retain cycle") }
  
  // UI:
  
  
  
};
