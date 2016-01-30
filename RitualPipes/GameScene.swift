//
//  GameScene.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright (c) 2016 tec. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var tileSize: CGFloat = 0.0
    
    var gridLayer: SKNode?
    var pipesLayer = SKNode()
    var firstPipeCheckpoint: SKSpriteNode?
    var pipeTip: SKSpriteNode?
    let pipeTipLinkShapeNode = SKShapeNode()
    var pipeTipLinkPath = CGPathCreateMutable()
    
    var currentLevel: Level!
    var currentLevelIdx = 0
    var dragAllowed = false
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.whiteColor()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        pipesLayer.zPosition = 2
        self.addChild(pipesLayer)
        
        loadNextLevel()
    }
    
    func loadNextLevel() {
        currentLevel = Level(idx: ++currentLevelIdx)
        tileSize = computeTileSize()
        
        if gridLayer != nil {
            gridLayer?.removeFromParent()
        }
        gridLayer = SKSpriteNode(texture: createGridTexture())
        gridLayer!.zPosition = 1
        self.addChild(gridLayer!)
        
        let blocksLayerPosition = computeBlocksLayerPosition()
        
        pipesLayer.position = blocksLayerPosition
        setupPipes()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if let touch = touches.first as UITouch? {
            
            let touchLocation = touch.locationInNode(pipesLayer)
            let touchedNode = pipesLayer.nodeAtPoint(touchLocation)
            
            dragAllowed = touchedNode == firstPipeCheckpoint!
            
            if dragAllowed {
                
                pipeTip = SKSpriteNode(texture: createPipeTipTexture())
                pipeTip!.position = touchLocation
                pipesLayer.addChild(pipeTip!)
                
                createPipeTipLinkPath()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            if dragAllowed {
                
                let touchLocation = touch.locationInNode(pipesLayer)
                let touchPreviousLocation = touch.previousLocationInNode(pipesLayer)
                
                let dX = touchLocation.x - touchPreviousLocation.x
                let dY = touchLocation.y - touchPreviousLocation.y
                
                pipeTip!.position.x += dX
                pipeTip!.position.y += dY
                
                createPipeTipLinkPath()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if pipeTip != nil {
            pipeTip!.removeFromParent()
            pipeTipLinkShapeNode.path = CGPathCreateMutable()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setupPipes() {
        if pipesLayer.children.count > 0 {
            pipesLayer.removeAllChildren()
        }
        
        let pipeCheckpoints = currentLevel.pipeCheckpoints
        
        for pipeCheckpoint in pipeCheckpoints {
            
            // Initial pipe checkpoint :)
            if pipeCheckpoint.order == 1 {
                firstPipeCheckpoint = SKSpriteNode(texture: createPipeCheckpointTexture())
                firstPipeCheckpoint!.position = pointForColumn(pipeCheckpoint.tile.column, row: pipeCheckpoint.tile.row)
                pipesLayer.addChild(firstPipeCheckpoint!)
            }
        }
        
        pipeTipLinkShapeNode.lineWidth = tileSize/1.5
        pipeTipLinkShapeNode.strokeColor = UIColor(red: 0.922, green: 0.000, blue: 0.000, alpha: 1.000)
        pipesLayer.addChild(pipeTipLinkShapeNode)
    }
    
    func createPipeTipLinkPath() {
        
        pipeTipLinkPath = CGPathCreateMutable()
        CGPathMoveToPoint(pipeTipLinkPath, nil, firstPipeCheckpoint!.position.x, firstPipeCheckpoint!.position.y)
        CGPathAddLineToPoint(pipeTipLinkPath, nil, pipeTip!.position.x, pipeTip!.position.y)
        pipeTipLinkShapeNode.path = pipeTipLinkPath
    }
    
    func computeBlocksLayerPosition() -> CGPoint {
        return CGPoint(
            x: -tileSize * CGFloat(currentLevel.colsCount) / 2,
            y: -tileSize * CGFloat(currentLevel.rowsCount) / 2
        )
    }
    
    func computeTileSize() -> CGFloat {
        return ((size.width / CGFloat(currentLevel.colsCount)) -
            (GameSceneMetrics.sceneMargin / CGFloat(currentLevel.colsCount))).normalizePixelPerfect()
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*tileSize + tileSize/2,
            y: CGFloat(row)*tileSize + tileSize/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(currentLevel.colsCount)*tileSize &&
            point.y >= 0 && point.y < CGFloat(currentLevel.rowsCount)*tileSize {
                return (true, Int(point.x / tileSize), Int(point.y / tileSize))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func convertPoint2(point: CGPoint) -> (column: Int, row: Int) {
        let c = point.x / tileSize
        let r = point.y / tileSize
        return (Int(c > 0 ? c : round(c)), Int(r > 0 ? r : round(r)))
    }
    
    // --------
    // Textures
    
    func createGridTexture() -> SKTexture? {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(currentLevel.colsCount) * tileSize, height: CGFloat(currentLevel.rowsCount) * tileSize), false, UIScreen.mainScreen().scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        for i in 0..<currentLevel.rowsCount {
            for j in 0..<currentLevel.colsCount {
                let evenColor = UIColor(red: 0.706, green: 0.706, blue: 0.706, alpha: 1.000)
                let oddColor = evenColor.colorWithHighlight(0.08)
                CGContextSetFillColorWithColor(ctx, (i % 2 == 0 ? j : (j + 1)) % 2 == 0 ? evenColor.CGColor : oddColor.CGColor)
                CGContextFillRect(ctx, CGRectMake(CGFloat(j) * tileSize, CGFloat(i) * tileSize, tileSize, tileSize))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    func createPipeCheckpointTexture() -> SKTexture? {
        
        let size: CGSize = CGSize(width: tileSize, height: tileSize)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let circleRect = CGRectMake(size.width/6, size.width/6, size.width/1.5, size.height/1.5)
        CGContextSetFillColorWithColor(ctx, UIColor(red: 0.922, green: 0.000, blue: 0.000, alpha: 1.000).CGColor)
        CGContextFillEllipseInRect(ctx, circleRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    func createPipeTipTexture() -> SKTexture? {
        
        return createPipeCheckpointTexture()
    }
}

class GameSceneMetrics {
    class var sceneMargin: CGFloat {
        let divider: CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 3.5 : 6.4
        return (UIScreen.mainScreen().bounds.width / divider).normalizePixelPerfect()
    }
}
