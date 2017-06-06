import SpriteKit

// Helpers:
private extension SKScene {
  func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
}
private func halfHeight(_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
private func halfWidth (_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
}

class CostumeSprite: SKSpriteNode {
  
  init(color: SKColor, size: CGSize) {
    super.init(texture: nil, color: color, size: size)
    isUserInteractionEnabled = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
}


/// The scene in which we can interact with our shop and player:
class ShopScene: SKScene {
  
  // Properties:
  private lazy var shop: Shop = Shop(shopScene: self)
  
  let previousGameScene: GameScene
  
  var player: Player { return self.previousGameScene.player }    // The player is actually still in the other scene, not this one
  
  private var selectedNode = SKSpriteNode()      // Changes as you click around the screen
  private var costumeNodes = [SKSpriteNode]()    // All costume textures will be node-ified here
  
  private let
  playerAvatarNode = SKSpriteNode(),
  buyNode  = SKLabelNode(),
  exitNode = SKLabelNode()
  
  private func setUpNodes() {
    // Node names are used for determining if buttons are pressed / costumes are touched.
    
    setupBuyNode: do {
      buyNode.text = "Buy Costume"
      buyNode.fontName = "Chalkduster"
      buyNode.position.y = frame.minY + halfHeight(buyNode)
      buyNode.name = "buy"
    }
    
    setupCostumeNodes: do {
      guard Costume.allCostumes.count > 1 else { fatalError("must have at least two costumes (for while loop)") }
      
      func costumeSpriteNode(costume: Costume) -> SKSpriteNode {
        let csn = SKSpriteNode(texture: costume.texture)
        csn.name = costume.name
        return csn
      }
      
      for costume in Costume.allCostumes { costumeNodes.append(costumeSpriteNode(costume: costume)) }
      guard costumeNodes.count == Costume.allCostumes.count else { fatalError("duplicate nodes found, or nodes are missing") }
      
      func findStartingPosition(offset: CGFloat, yPos: CGFloat) -> CGPoint {   // Find the correct position to have all costumes centered on screen.
        let
        count = CGFloat(costumeNodes.count),
        totalOffsets = (count - 1) * offset,
        textureWidth = Costume.list.gray.texture.size().width,    // All textures must be same width for centering to work.
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
    
      setupPlayerAvatarNode: do {
        guard let texture = player.texture else { fatalError("player has no texture!! Is .wear()ing costume?") }
        playerAvatarNode.texture = texture
        playerAvatarNode.size = texture.size()
        playerAvatarNode.position.y += 200
      }
      
      setupExitNode: do {
        exitNode.text = "Leave Shop"
        exitNode.fontName = "Chalkduster"
        exitNode.position.y = frame.maxY - halfHeight(buyNode)
      }
      
      finallyAddThemAllToScene: do {
        addChildren(costumeNodes)
        addChildren([playerAvatarNode, buyNode, exitNode])
      }
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

  // Touch handling:

  // I'm choosing to have the buttons activated by searching for name here. You can also
  // subclass a node and have them do actions on their own when clicked.
  override func mouseDown(with event: NSEvent) {
    // shop.exitShop()
    
    let location = event.location(in: self)
    
    // Check if we clicked a costume:
    for node in costumeNodes {
      guard let name = atPoint(location).name else { continue }
      if name == node.name {
          selectedNode = node
      }
    }
    
  }
};
