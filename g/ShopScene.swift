import SpriteKit

// Helpers:
private extension SKNode {
  func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
  
  func addChildrenBehind(_ nodes: [SKNode]) { for node in nodes {
    node.zPosition -= 2
    addChild(node)
    }
  }
}
private func halfHeight(_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
private func halfWidth (_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }


// MARK: -
/// Just a UI representation, does not manipulate any models.
final class CostumeNode: SKSpriteNode {
  // FIXME: Why does the gray shirt fucking 0 get blotted out?
  let costume:   Costume
  weak private(set) var player: Player
  
  private(set) var
  backgroundNode = SKSpriteNode(),
  nameNode       = SKLabelNode(),
  priceNode      = SKLabelNode()
  
  private func label(text: String, size: CGSize) -> SKLabelNode {
    let label = SKLabelNode(text: text)
    label.fontName = "Chalkduster"
    // FIXME: deform to fit:
    return label
  }
  
  private func setupNodes(with size: CGSize) {
    
    let circle = SKShapeNode(circleOfRadius: size.width)
    circle.fillColor = .yellow
    let bkg = SKSpriteNode(texture: SKView().texture(from: circle))
    bkg.zPosition -= 1
    
    let name = label(text: "\(costume.name)", size: size)
    name.position.y = frame.maxY + name.frame.size.height
    
    let price = label(text: "\(costume.price)", size: size)
    price.position.y = frame.minY - price.frame.size.height
    
    addChildrenBehind([bkg, name, price])
    (backgroundNode, nameNode, priceNode) = (bkg, name, price)
  }
  
  init(costume: Costume, player: Player) {
    self.player = player
    self.costume = costume
    
    let size = costume.texture.size()
    super.init(texture: costume.texture, color: .clear, size: size)
    
    name = costume.name   // Name is needed for sorting and detecting touches.
    
    setupNodes(with: size)
    becomesUnselected()
  }
  
  private func setPriceText() {
    
    func playerCanAfford() {
      priceNode.text = "\(costume.price)"
      priceNode.fontColor = .white
    }
    
    func playerCantAfford() {
      priceNode.text = "\(costume.price)"
      priceNode.fontColor = .red
    }
    
    func playerOwns() {
      priceNode.text = ""
      priceNode.fontColor = .white
    }
    
    if
  }
  func becomesSelected() {    // For animation / sound purposes (could also just be handled by the ShopScene).
    backgroundNode.run(.fadeAlpha(to: 0.75, duration: 0.25))
    // insert sound if desired.
  }
  
  func becomesUnselected() {
    backgroundNode.run(.fadeAlpha(to: 0, duration: 0.10))
    // insert sound if desired.
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
};


// MARK: -
/// The scene in which we can interact with our shop and player:
class ShopScene: SKScene {
  
  private lazy var shop: Shop = Shop(shopScene: self)
  
  let previousGameScene: GameScene
  
  var player: Player { return self.previousGameScene.player }    // The player is actually still in the other scene, not this one.
  
  private var costumeNodes = [CostumeNode]()                   // All costume textures will be node-ified here.
  
  lazy private(set) var selectedNode: CostumeNode? = {
    return self.costumeNodes.first!
  }()
  
  private let
  buyNode  = SKLabelNode(fontNamed: "Chalkduster"),
  coinNode = SKLabelNode(fontNamed: "Chalkduster"),
  exitNode = SKLabelNode(fontNamed: "Chalkduster")
  
  // MARK: - Node setup:
  private func setUpNodes() {
    
    buyNode.text = "Buy Costume"
    buyNode.name = "buynode"
    buyNode.position.y = frame.minY + halfHeight(buyNode)
    
    coinNode.text = "Coins: \(player.coins)"
    coinNode.name = "coinnode"
    coinNode.position = CGPoint(x: frame.minX + halfWidth(coinNode), y: frame.minY + halfHeight(coinNode))
  
    exitNode.text = "Leave Shop"
    exitNode.name = "exitnode"
    exitNode.position.y = frame.maxY - halfHeight(buyNode)
    
    setupCostumeNodes: do {
      guard Costume.allCostumes.count > 1 else {
        fatalError("must have at least two costumes (for while loop)")
      }
      for costume in Costume.allCostumes {
        costumeNodes.append(CostumeNode(costume: costume))
      }
      guard costumeNodes.count == Costume.allCostumes.count else {
        fatalError("duplicate nodes found, or nodes are missing")
      }
      
      let offset = CGFloat(150)
      
      func findStartingPosition(offset: CGFloat, yPos: CGFloat) -> CGPoint {   // Find the correct position to have all costumes centered on screen.
        let
        count = CGFloat(costumeNodes.count),
        totalOffsets = (count - 1) * offset,
        textureWidth = Costume.list.gray.texture.size().width,                 // All textures must be same width for centering to work.
        totalWidth = (textureWidth * count) + totalOffsets
        
        let measurementNode = SKShapeNode(rectOf: CGSize(width: totalWidth, height: 0))
        
        return CGPoint(x: measurementNode.frame.minX + textureWidth/2, y: yPos)
      }
      
      costumeNodes.first!.position = findStartingPosition(offset: offset, yPos: self.frame.midY)
      
      var counter = 1
      let finalIndex = costumeNodes.count - 1
      // Place nodes from left to right:
      while counter <= finalIndex {
        let thisNode = costumeNodes[counter]
        let prevNode = costumeNodes[counter - 1]
        
        thisNode.position.x = prevNode.frame.maxX + halfWidth(thisNode) + offset
        counter += 1
      }
    }
    
    addChildren(costumeNodes)
    addChildren([buyNode, coinNode, exitNode])
  }
  
  // MARK: - Init:
  init(previousGameScene: GameScene) {
    self.previousGameScene = previousGameScene
    super.init(size: previousGameScene.size)
    print("new scene")
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
  
  deinit { print("shopscene: if you don't see this message when exiting shop then you have a retain cycle") }
  
  // MARK: - Game loop:
  override func didMove(to view: SKView) {
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    setUpNodes()
    select(costumeNodes.first!)
  }
  
  // MARK: - Touch handling:
  private func unselect(_ costumeNode: CostumeNode) {
    selectedNode = nil
    costumeNode.becomesUnselected()
  }
  
  // Adjusts UI elements:
  private func select(_ costumeNode: CostumeNode) {
    unselect(selectedNode!)
    selectedNode = costumeNode
    costumeNode.becomesSelected()
  
    if shop.soldCostumes.contains(costumeNode.costume) {      // Wear selected costume if owned.
      player.costume = costumeNode.costume
      buyNode.text = "Bought Costume"
      buyNode.alpha = 1
    }
      
    else if player.coins < costumeNode.costume.price { // Can't afford costume.
      buyNode.text = "Buy Costume"
      buyNode.alpha = 0.5
    }
    
    else {                                            // Player can buy costume.
      buyNode.text = "Buy Costume"
      buyNode.alpha = 1
      }
  }

  override func update(_ currentTime: TimeInterval) {

  }
  
  // I'm choosing to have the buttons activated by searching for name here. You can also
  // subclass a node and have them do actions on their own when clicked.
  override func mouseDown(with event: NSEvent) {
    
    guard let selectedNode = selectedNode else { fatalError() }
    let location    = event.location(in: self)
    let clickedNode = atPoint(location)
    
    switch clickedNode {
      
      // Clicked empty space:
      case is ShopScene:
        return
        
      // Clicked Buy / Leave:
      case is SKLabelNode:
        if clickedNode.name == "exitnode" { view!.presentScene(previousGameScene) }
        
        if clickedNode.name == "buynode"  {
          
          if shop.canBuyCostume(selectedNode.costume) {
            shop.buyCostume(selectedNode.costume)
            coinNode.text = "Coins: \(player.coins)"
            buyNode.text = "Bought"
          }
        }
        
      // Clicked a costume:
      case let clickedCostume as CostumeNode:
        for node in costumeNodes {
          if node.name == clickedCostume.name {
            select(clickedCostume)
          }
        }
        
      default: ()
      }
  }
};
