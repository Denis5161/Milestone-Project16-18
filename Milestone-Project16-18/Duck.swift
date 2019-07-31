//
//  Duck.swift
//  Milestone-Project16-18
//
//  Created by Denis Goldberg on 31.07.19.
//  Copyright © 2019 Denis Goldberg. All rights reserved.
//

import UIKit
import SpriteKit

class Duck: SKSpriteNode {
    var scoreMultiplier: Int!
    
    func randomizeDuck() {
        if Int.random(in: 0...1) == 0 {
            texture = SKTexture(imageNamed: "duckBad")
            name = "duckEnemy"
        } else {
            texture = SKTexture(imageNamed: "duckGood")
            name = "duckFriend"
        }
        
        if Int.random(in: 0...2) > 1 {
            scale(to: CGSize(width: self.size.width / 2, height: self.size.height / 2))
            scoreMultiplier = 20
        } else {
            scoreMultiplier = 1
        }
    }
}
