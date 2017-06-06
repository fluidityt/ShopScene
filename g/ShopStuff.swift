import SpriteKit

// Helpers:
extension SKScene {
  func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
}
fileprivate func halfHeight(_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
fileprivate func halfWidth (_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
fileprivate func costumeSpriteNode(costume: Costume) -> SKSpriteNode {
  let csn = SKSpriteNode(texture: costume.texture)
  csn.name = costume.name
  return csn
}

/// Our model class to be used inside of our ShopScene:
class Shop {
  
  // The scene in which this shop will be called from:
  weak private(set) var scene: ShopScene!
  
  var player: Player { return scene.player }
  
  // Add each costume you want to be available for purchase to the player at this time:
  // (The green shirt wont become available until the player has cleared 2 levels)
  var availableCostumes: [Costume] = [Costume.list.red, Costume.list.blue]
  
  // Keeps track of sold costumes:
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
  
  // The player is actually still in the other scene, not this one
  var player: Player { return self.previousGameScene.player }
  
  // Changes as you click around the screen
  private var selectedNode = SKSpriteNode()
  private var costumeNodes = [SKSpriteNode]()
  
  // The things you click to interact with / view the shop:
  private let
  playerAvatarNode = SKSpriteNode(),
  buyNode  = SKLabelNode(),
  exitNode = SKLabelNode()
  
  // Node names are used for determining if buttons are pressed, costumes are touched..
  private func setUpNodes() {
    
    setupBuyNode: do {
      buyNode.text = "Buy Costume"
      buyNode.fontName = "Chalkduster"
      buyNode.position.y = frame.minY + halfHeight(buyNode)
      buyNode.name = "buy"
    }
    
    setupCostumeNodes: do {
      guard Costume.allCostumes.count > 1 else { fatalError("must have at least two costumes (for while loop)") }
      
      for costume in Costume.allCostumes {
        costumeNodes.append(costumeSpriteNode(costume: costume))
      }
      guard costumeNodes.count == Costume.allCostumes.count else { fatalError("duplicate nodes found") }
      
      costumeNodes[0].position.x = frame.minX + halfWidth(costumeNodes[0])
      var counter = 1
      let finalIndex = costumeNodes.count - 1
      
      // Place nodes from left to right:
      while counter <= finalIndex {
        let thisNode = costumeNodes[counter]
        let prevNode = costumeNodes[counter - 1]
        
        thisNode.position.x = prevNode.frame.maxX + halfWidth(thisNode) + 50
        counter += 1
      }
    }
    
    setupPlayerAvatarNode: do {
      guard let texture = player.texture else { fatalError("player has no texture!! Is .wear()ing costume?") }
      playerAvatarNode.texture = texture
      playerAvatarNode.size = texture.size()
    }
    
    setupExitNode: do {
      exitNode.text = "Leave Shop"
      exitNode.fontName = "Chalkduster"
      exitNode.position.y = frame.maxY - halfHeight(buyNode)
    }
    
    // Add them to scene:
    addChildren(costumeNodes)
    addChildren([selectedNode, playerAvatarNode, buyNode, exitNode])
    
  }
  
  // Init:
  init(previousGameScene: GameScene) {
    self.previousGameScene = previousGameScene
    super.init(size: previousGameScene.size)
    print("new scene")
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
  
  deinit { print("shopscene: if you don't see this message when exiting shop then you have a retain cycle") }
  
  // Game loop:
  override func didMove(to view: SKView) {
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    setUpNodes()
  }
  
  // I'm choosing to have the buttons activated by searching for name here. You can also
  // subclass a node and have them do actions on their own when clicked.
  override func mouseDown(with event: NSEvent) {
    shop.exitShop()
  }
};
