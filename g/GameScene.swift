    import SpriteKit

    class GameScene: SKScene {
      
      let player = Player(costume: Costume.defaultCostume)
      
      lazy var enterNode:  SKLabelNode = { return (self.childNode(withName: "entershop")  as! SKLabelNode) }()
      lazy var coinNode:   SKLabelNode = { return (self.childNode(withName: "getcoins" )  as! SKLabelNode) }()
      lazy var coinLabel:  SKLabelNode = { return (self.childNode(withName: "coinlabel")  as! SKLabelNode) }()
      lazy var levelLabel: SKLabelNode = { return (self.childNode(withName: "levellabel") as! SKLabelNode) }()
      
      override func didMove(to view: SKView) {
        player.name = "player"
        if player.scene == nil { addChild(player) }
      }
      
      override func mouseDown(with event: NSEvent) {
        
        let location = event.location(in: self)
        
        if let name = atPoint(location).name {
          
          switch name {
            
          case "entershop": view!.presentScene(ShopScene(previousGameScene: self))
            
          case "getcoins":  player.getCoins(1)
            
          default: ()
          }
        }
          
        else {
          player.run(.move(to: location, duration: 1))
        }
      }
      
      override func update(_ currentTime: TimeInterval) {
      
        func levelUp(_ level: Int) {
          player.levelsCompleted = level
          levelLabel.text = "Level: \(player.levelsCompleted)"
        }
        
        switch player.coins {
          case 10: levelUp(2)
          case 20: levelUp(3)
          case 30: levelUp(4)
          default: ()
        }
      }
    };
