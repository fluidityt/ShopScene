import SpriteKit

// Helpers:
private extension SKScene {
  func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
}
private func halfHeight(_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
private func halfWidth (_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }


// MARK: -
/// Just a UI representation, does not manipulate any models.
class CostumeSprite: SKSpriteNode {
  
  let costume:   Costume
  let backgroundNode
  let nameNode
  let priceNode
  init(costume: Costume) {
    self.costume   = costume
    
    super.init(texture: costume.texture, color: .clear, size: costume.texture.size())
    name = costume.name   // Name is needed for sorting and detecting touches.
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
};


// MARK: -
/// The scene in which we can interact with our shop and player:
class ShopScene: SKScene {
  
  private lazy var shop: Shop = Shop(shopScene: self)
  
  let previousGameScene: GameScene
  
  var player: Player { return self.previousGameScene.player }    // The player is actually still in the other scene, not this one
  
  private var costumeNodes = [CostumeSprite]()                   // All costume textures will be node-ified here
  lazy private(set) var selectedNode: CostumeSprite = {
    return self.costumeNodes.first!
  }()
  
  private let buyNode  = SKLabelNode(fontNamed: "Chalkduster")
  private let exitNode = SKLabelNode(fontNamed: "Chalkduster")
  
  private func unselect(_ costumeNode: CostumeSprite) {
    costumeNode.
  }

  private func select(_ costumeNode: CostumeSprite) {
    unselect(selectedNode)
    selectedNode = costumeNode
    
  }
  
  
  // MARK: - Node setup:
  private func setUpNodes() {
    
    buyNode.text = "Buy Costume"
    buyNode.name = "buynode"
    buyNode.position.y = frame.minY + halfHeight(buyNode)
    
    exitNode.text = "Leave Shop"
    exitNode.name = "exitnode"
    exitNode.position.y = frame.maxY - halfHeight(buyNode)
    
    setupCostumeNodes: do {
      guard Costume.allCostumes.count > 1 else {
        fatalError("must have at least two costumes (for while loop)")
      }
      for costume in Costume.allCostumes {
        costumeNodes.append(CostumeSprite(costume: costume))
      }
      guard costumeNodes.count == Costume.allCostumes.count else {
        fatalError("duplicate nodes found, or nodes are missing")
      }
      
      func findStartingPosition(offset: CGFloat, yPos: CGFloat) -> CGPoint {   // Find the correct position to have all costumes centered on screen.
        let
        count = CGFloat(costumeNodes.count),
        totalOffsets = (count - 1) * offset,
        textureWidth = Costume.list.gray.texture.size().width,                 // All textures must be same width for centering to work.
        totalWidth = (textureWidth * count) + totalOffsets
        
        let measurementNode = SKShapeNode(rectOf: CGSize(width: totalWidth, height: 0))
        
        return CGPoint(x: measurementNode.frame.minX + textureWidth/2, y: yPos)
      }
      
      costumeNodes.first!.position = findStartingPosition(offset: 50, yPos: self.frame.midY)
      
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
    
    addChildren(costumeNodes)
    addChildren([buyNode, exitNode])
    
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
  }

  // MARK: - Touch handling:

  // I'm choosing to have the buttons activated by searching for name here. You can also
  // subclass a node and have them do actions on their own when clicked.
  override func mouseDown(with event: NSEvent) {
    
    let location = event.location(in: self)
    let clickedNode     = atPoint(location)
    
    if clickedNode is SKLabelNode {
      if clickedNode.name == "exitnode" { view!.presentScene(previousGameScene) }
    }

    guard let clickedCostume = clickedNode as? CostumeSprite else {
      return  // We have nothing else on the screen to interact with except costumes
    }
    
    for node in costumeNodes {
      
      if node.name == clickedCostume.name {
        selectedNode = clickedCostume
      }
      
      
    }
    
  }
};
