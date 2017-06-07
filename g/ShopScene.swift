    import SpriteKit

    // Helpers:
    extension SKNode {
      func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }
      
      func addChildrenBehind(_ nodes: [SKNode]) { for node in nodes {
        node.zPosition -= 2
        addChild(node)
        }
      }
    }
     func halfHeight(_ node: SKNode) -> CGFloat { return node.frame.size.height/2 }
     func halfWidth (_ node: SKNode) -> CGFloat { return node.frame.size.width/2 }


    // MARK: -
    /// The scene in which we can interact with our shop and player:
    class ShopScene: SKScene {
      
      lazy private(set) var shop: Shop = { return Shop(shopScene: self) }()
      
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
        exitNode.position.y = frame.maxY - buyNode.frame.height
        
        setupCostumeNodes: do {
          guard Costume.allCostumes.count > 1 else {
            fatalError("must have at least two costumes (for while loop)")
          }
          for costume in Costume.allCostumes {
            costumeNodes.append(CostumeNode(costume: costume, player: player))
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
      }
      
      required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")}
      
      deinit { print("shopscene: if you don't see this message when exiting shop then you have a retain cycle") }
      
      // MARK: - Game loop:
      override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUpNodes()
        
        select(costumeNodes.first!)                           // Default selection.
        for node in costumeNodes {
          if node.costume == player.costume { select(node) }
        }
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
      
        if player.hasCostume(costumeNode.costume) {      // Wear selected costume if owned.
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
              // guard let shop = shop else { fatalError("where did the shop go?") }
              if shop.canSellCostume(selectedNode.costume) {
                shop.sellCostume(selectedNode.costume)
                coinNode.text = "Coins: \(player.coins)"
                buyNode.text = "Bought Costume"
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
