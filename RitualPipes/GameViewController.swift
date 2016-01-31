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
    var scene: GameScene!
    var gameSubControlsView: GameSubControlsView!
    
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
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        // Sub controls view
        gameSubControlsView = GameSubControlsView(frame: CGRectMake(0, 0, skView.bounds.width, 0))
        gameSubControlsView.goalButton.addTarget(self, action: "showLevelGoal", forControlEvents: .TouchDown)
        gameSubControlsView.goalButton.addTarget(self, action: "hideLevelGoal", forControlEvents: .TouchUpInside)
        gameSubControlsView.goalButton.addTarget(self, action: "hideLevelGoal", forControlEvents: .TouchUpOutside)
        gameSubControlsView.goalButton.multipleTouchEnabled = false
        skView.addSubview(gameSubControlsView)
        
        gameSubControlsView.sizeToFit()
        gameSubControlsView.frame.origin.y = skView.bounds.height - gameSubControlsView.bounds.height
    }
    
    func showLevelGoal() {
        scene.levelPreviewLayer.hidden = false
        gameSubControlsView.goalButton.hidden = true
        scene.userInteractionEnabled = false
    }
    
    func hideLevelGoal() {
        
        scene.levelPreviewLayer.hidden = true
        gameSubControlsView.goalButton.hidden = false
        scene.userInteractionEnabled = true
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
