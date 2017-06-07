    import SpriteKit

    /// Just a UI representation, does not manipulate any models.
    final class CostumeNode: SKSpriteNode {
      
      let costume:   Costume
      
      weak private(set) var player: Player!
      
      private(set) var
      backgroundNode = SKSpriteNode(),
      nameNode       = SKLabelNode(),
      priceNode      = SKLabelNode()
      
      private func label(text: String, size: CGSize) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Chalkduster"
        // FIXME: deform label to fit size and offset
        return label
      }
      
      init(costume: Costume, player: Player) {
      
         func setupNodes(with size: CGSize) {
          
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
        
        self.player = player
        self.costume = costume
        
        let size = costume.texture.size()
        super.init(texture: costume.texture, color: .clear, size: size)
        
        name = costume.name   // Name is needed for sorting and detecting touches.
        
        setupNodes(with: size)
        becomesUnselected()
      }
      
      private func setPriceText() { // Updates the color and text of price labels
        
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
        
        if player.hasCostume(self.costume)         { playerOwns()       }
        else if player.coins < self.costume.price  { playerCantAfford() }
        else if player.coins >= self.costume.price { playerCanAfford()  }
        else                                       { fatalError()       }
      }
      
      func becomesSelected() {    // For animation / sound purposes (could also just be handled by the ShopScene).
        backgroundNode.run(.fadeAlpha(to: 0.75, duration: 0.25))
        setPriceText()
        // insert sound if desired.
      }
      
      func becomesUnselected() {
        backgroundNode.run(.fadeAlpha(to: 0, duration: 0.10))
        setPriceText()
        // insert sound if desired.
      }
      
      required init?(coder aDecoder: NSCoder) { fatalError() }
      
      deinit { print("costumenode: if you don't see this then you have a retain cycle") }
    };
