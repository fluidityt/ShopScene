
import SpriteKit

// Placeholder texture since I'm too lazy to add actual art:
let tex = SKTexture(noiseWithSmoothness: 22, size: CGSize(width: 50, height: 50), grayscale: false)

typealias Price = Int

/// The items that are for sale in our shop:
struct Costume {
  
  static var allCostumes: [Costume] = []

  let name: String
  let texture: SKTexture
  let price: Price
  
  // This init simply adds all costumes to a master list for easy sorting later on.
  init(name: String, texture: SKTexture, price: Price) { self.name = name; self.texture = texture; self.price = price
    Costume.allCostumes.append(self)
  }
  
  // Hard-code any new costumes you create here (this is a "master list" of costumes):
  // (make sure all of your costumes have a unique name, or the program will not work properly)
  static let list = (
    gray:  Costume(name: "Gray Shirt",  texture: tex/*SKTexture(imageNamed: "grayshirt")*/,  price:  0),
    red:   Costume(name: "Red Shirt",   texture: tex/*SKTexture(imageNamed: "redshirt")*/,   price: 25),
    blue:  Costume(name: "Blue Shirt",  texture: tex/*SKTexture(imageNamed: "blueshirt")*/,  price: 50),
    green: Costume(name: "Green Shirt", texture: tex/*SKTexture(imageNamed: "greenshirt")*/, price: 75)
  )
  
  static let defaultCostume = list.gray
};

// The reason why you need unique names:
func == (lhs: Costume, rhs: Costume) -> Bool {
  if lhs.name == rhs.name { return true }
  else { return false }
}

// Makes using our costume array in ShopScene easier:
extension Array {
  func contains(_ costume: Costume) -> Bool {
    return false
  }
}

class Player: SKSpriteNode {
  
  var coins = 0
  var costume: Costume
  var levelsCompleted = 0
  
  init(costume: Costume) {
    self.costume = costume
    super.init(texture: costume.texture, color: .clear, size: costume.texture.size())
  }
  
  // Does nothing for us but is required:
  required init?(coder aDecoder: NSCoder) { fatalError() }
};

class GameScene: SKScene {
  
  let player = Player(costume: Costume.defaultCostume)
  
  override func didMove(to view: SKView) {
    // addChild(player)
  }
  override func mouseDown(with event: NSEvent) {
    view!.presentScene(ShopScene(previousGameScene: self))
  }
};
