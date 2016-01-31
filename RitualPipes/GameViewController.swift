//
//  GameViewController.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright (c) 2016 tec. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var skView: SKView!
    
    override func loadView() {
        super.loadView()
        
        skView = SKView(frame : UIScreen.mainScreen().bounds)
        self.view = skView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView.multipleTouchEnabled = false
        skView.ignoresSiblingOrder = true
        
        // Debug
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        
        // Create/configure the scene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
