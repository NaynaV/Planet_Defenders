//
//  MainMenu.swift
//  Planet_Defenders
//
//  Created by Simran Thakkar on 2020-06-19.
//  Copyright © 2020 Farzaad Goiporia. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {


    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "main_screen")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.setScale(1.25)
        addChild(background)
    }
    
    func loadGame() {
        
       let myScene = GameScene(size: size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.fade(withDuration: 1.5)
        view?.presentScene(myScene, transition: reveal)
        }
    
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
      loadGame()
    }

    }





