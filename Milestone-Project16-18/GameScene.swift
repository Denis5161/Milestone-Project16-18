//
//  GameScene.swift
//  Milestone-Project16-18
//
//  Created by Denis Goldberg on 31.07.19.
//  Copyright © 2019 Denis Goldberg. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var gameOverLabel: SKSpriteNode!
    var gameIsOver = false
    
    var gameTimer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var secondsRemaining = 60 {
        didSet {
            timerLabel.text = "Time Left: \(secondsRemaining) \(secondsRemaining == 1 ? "Second" : "Seconds")"
        }
    }
    
    var shotFinder: SKSpriteNode!
    var shotsLeftLabel: SKSpriteNode!
    var reloadLabel: SKLabelNode!
    var shotSound = SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false)
    var reloadSound = SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false)
    var emptySound = SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false)
    var shotsLeft = 3 {
        didSet {
            shotsLeftLabel.texture = SKTexture(imageNamed: "shots\(shotsLeft)")
            switch shotsLeft {
            case 3:
                run(reloadSound)
            case 0...2:
                run(shotSound)
            default:
                preconditionFailure("Variable shotsLeft shouldn't be below 0.")
            }
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.11, green: 0.64, blue: 0.93, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "curtains")
        background.position = CGPoint(x: 512, y: 384)
        background.scale(to: CGSize(width: 1024, height: 768))
        background.zPosition = 1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.zPosition = 2
        timerLabel.position = CGPoint(x: 1008, y: 16)
        addChild(timerLabel)
        
        gameOverLabel = SKSpriteNode(imageNamed: "gameOver")
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.alpha = 0
        gameOverLabel.zPosition = 2
        addChild(gameOverLabel)
        
        shotFinder = SKSpriteNode(imageNamed: "cursor")
        shotFinder.isHidden = true
        shotFinder.zPosition = 2
        addChild(shotFinder)
        
        shotsLeftLabel = SKSpriteNode(imageNamed: "shots3")
        shotsLeftLabel.position = CGPoint(x: 512, y: 32)
        shotsLeftLabel.zPosition = 2
        addChild(shotsLeftLabel)
        
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.position = CGPoint(x: 512, y: 96)
        reloadLabel.zPosition = 2
        reloadLabel.fontSize = 32
        reloadLabel.text = "RELOAD!"
        reloadLabel.name = "reload"
        addChild(reloadLabel)
        
        secondsRemaining = 60
        score = 0
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
    }
    
    @objc func createDuck() {
        secondsRemaining -= 1
        
        if secondsRemaining == 0 {
            gameTimer?.invalidate()
            gameOverLabel.run(SKAction.fadeIn(withDuration: 0.5))
        }
        
        let row = RowType.allCases.randomElement()!
        var vector = CGVector(dx: 2000, dy: 0)
        let duck = Duck(imageNamed: "duckGood")
        duck.randomizeDuck()
        
        switch row {
        case .upper:
            duck.position = CGPoint(x: 0, y: 768 * 0.66)
        case .middle:
            duck.position = CGPoint(x: 1024, y: 768 * 0.5)
            vector = CGVector(dx: -2000, dy: 0)
        case .lower:
            duck.position = CGPoint(x: 0, y: 768 * 0.33)
        }
        
        addChild(duck)
        duck.run(SKAction.move(by: vector, duration: TimeInterval.random(in: 2...7)))
    }

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x > 1024 || node.position.x < 0 {
                node.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }
        let tappedNodes = nodes(at: touchLocation)
        
        shotFinder.position = touchLocation
        
        if tappedNodes.contains(where: { $0.name == "reload"}) {
            shotsLeft = 3
            return
        }
        
        if shotsLeft != 0 {
            shotFinder.isHidden = false
            shotsLeft -= 1
            
            for node in tappedNodes {
                if let duckNode = node as? Duck {
                    duckNode.removeAllActions()
                    duckNode.run(SKAction.fadeOut(withDuration: 1)) { node.removeFromParent() }
                    
                    if duckNode.name == "duckEnemy" {
                        score += 1 * duckNode.scoreMultiplier
                    } else if duckNode.name == "duckFriend" {
                        score -= 1
                    }
                }
            }
        } else {
            shotFinder.isHidden = true
            run(emptySound)
        }
    }
}

enum RowType: CaseIterable {
    case upper
    case middle
    case lower
}
