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
    var levelPreviewLayer = SKNode()
    var currentPipeCheckpoint: SKSpriteNode?
    var currentPipeCheckpointCounter = 0
    var pipeTip: SKSpriteNode?
    let pipeTipLinkShapeNode = SKShapeNode()
    var pipeTipLinkPath = CGPathCreateMutable()
    
    var currentLevel: Level!
    var currentLevelIdx = 0
    var touchLocation = CGPointZero
    var dragAllowed = false
    
    var timer: NSTimer?
    var prevTouchedCol: Int?, prevTouchedRow: Int?
    
    // Sounds
    private let moveSound: SKAction = SKAction.playSoundFileNamed("move.m4a", waitForCompletion: false)
    var moveSoundPlaying = false
    private let rightSound: SKAction = SKAction.playSoundFileNamed("right.m4a", waitForCompletion: false)
    private let wrongSound: SKAction = SKAction.playSoundFileNamed("wrong.m4a", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.blackColor()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        pipesLayer.zPosition = 2
        self.addChild(pipesLayer)
        
        levelPreviewLayer.zPosition = 3
        self.addChild(levelPreviewLayer)
        
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
        gridLayer?.alpha = 0
        
        let blocksLayerPosition = computeBlocksLayerPosition()
        
        pipesLayer.position = blocksLayerPosition
        setupPipes()
        
        levelPreviewLayer.position = blocksLayerPosition
        setupLevelPreview()
        
        let repeatedIntroBlink = SKAction.repeatAction(SKAction.sequence([
            SKAction.runBlock({
                self.levelPreviewLayer.hidden = false
            }),
            SKAction.waitForDuration(0.23),
            SKAction.runBlock({
                self.levelPreviewLayer.hidden = true
            }),
            SKAction.waitForDuration(0.23)]), count: 3)
        
        self.runAction(repeatedIntroBlink, completion: { completed in
            
            self.userInteractionEnabled = true
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if let touch = touches.first as UITouch? {
            
            touchLocation = touch.locationInNode(pipesLayer)
            let touchedNode = pipesLayer.nodeAtPoint(touchLocation)
            
            dragAllowed = touchedNode == currentPipeCheckpoint!
            
            if dragAllowed {
                
                pipeTip = SKSpriteNode(texture: createPipeTipTexture())
                pipeTip!.position = touchLocation
                pipesLayer.addChild(pipeTip!)
                
                createPipeTipLinkPath()
                
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
            }
        }
    }
    
    func timerUpdate() {
        
        let nextModelPipeCheckpoint = self.nextModelPipeCheckpoint()
        let (touchCol, touchRow) = convertPoint2(touchLocation)
        
        if touchCol == nextModelPipeCheckpoint?.tile.column &&
            touchRow == nextModelPipeCheckpoint?.tile.row {
                
                let pipeCheckpoint = SKSpriteNode(texture: createPipeCheckpointTexture())
                pipeCheckpoint.position = pointForColumn(touchCol, row: touchRow)
                pipesLayer.addChild(pipeCheckpoint)
                
                let pipePath = CGPathCreateMutable()
                CGPathMoveToPoint(pipePath, nil, currentPipeCheckpoint!.position.x, currentPipeCheckpoint!.position.y)
                CGPathAddLineToPoint(pipePath, nil, pipeCheckpoint.position.x, pipeCheckpoint.position.y)
                
                let pipeShapeNode = SKShapeNode(path: pipePath)
                pipeShapeNode.lineWidth = pipeTipLinkShapeNode.lineWidth
                pipeShapeNode.strokeColor = pipeTipLinkShapeNode.strokeColor
                pipesLayer.addChild(pipeShapeNode)
                
                currentPipeCheckpoint = pipeCheckpoint
                createPipeTipLinkPath()
                
                self.runAction(rightSound)
                
                if  currentPipeCheckpointCounter == currentLevelMaxOrder() - 1 {
                    win()
                }
                
                currentPipeCheckpointCounter++
        } else {
            reset()
            pipesLayer.removeAllChildren()
            setupPipes()
            self.runAction(wrongSound)
        }
    }
    
    func win() {
        
        userInteractionEnabled = false
        
        if (timer != nil) {
            timer?.invalidate()
        }
        
        dragAllowed = false
        
        if pipeTip != nil {
            pipeTip!.removeFromParent()
            pipeTipLinkPath = CGPathCreateMutable()
            pipeTipLinkShapeNode.path = pipeTipLinkPath
        }
        
        let repeatedWinBlink = SKAction.repeatAction(SKAction.sequence([
            SKAction.runBlock({
                self.pipesLayer.hidden = true
            }),
            SKAction.waitForDuration(0.23),
            SKAction.runBlock({
                self.pipesLayer.hidden = false
            }),
            SKAction.waitForDuration(0.23)]), count: 3)
        
        self.runAction(SKAction.sequence([repeatedWinBlink, SKAction.waitForDuration(0.7)]), completion: { completed in
            
            if self.currentLevelIdx >= 3 {
                self.currentLevelIdx = 0
            }
            self.loadNextLevel()
            
            self.userInteractionEnabled = true
        })
    }
    
    func currentLevelMaxOrder() -> Int {
        var maxOrder = 0
        for pipeCheckpoint in currentLevel.pipeCheckpoints {
            if pipeCheckpoint.order > maxOrder {
                maxOrder = pipeCheckpoint.order
            }
        }
        return maxOrder
    }
    
    func nextModelPipeCheckpoint() -> PipeCheckpoint? {
        for pipeCheckpoint in currentLevel.pipeCheckpoints {
            if pipeCheckpoint.order == currentPipeCheckpointCounter + 1 {
                return pipeCheckpoint
            }
        }
        return nil
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let (touchCol, touchRow) = convertPoint2(touchLocation)
            
            if dragAllowed {
                
                touchLocation = touch.locationInNode(pipesLayer)
                let touchPreviousLocation = touch.previousLocationInNode(pipesLayer)
                
                let dX = touchLocation.x - touchPreviousLocation.x
                let dY = touchLocation.y - touchPreviousLocation.y
                
                pipeTip!.position.x += dX
                pipeTip!.position.y += dY
                
                createPipeTipLinkPath()
                
                // Sound
                if touchCol != prevTouchedCol || touchRow != prevTouchedRow {
                    playMoveSound()
                }
            }
            
            prevTouchedCol = touchCol
            prevTouchedRow = touchRow
        }
    }
    
    func playMoveSound() {
        if !moveSoundPlaying {
            moveSoundPlaying = true
            self.runAction(moveSound, completion: { completed in
                
                self.moveSoundPlaying = false
            })
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if  currentPipeCheckpointCounter != currentLevelMaxOrder() {
            reset()
            pipesLayer.removeAllChildren()
            setupPipes()
        }
    }
    
    func reset() {
        touchLocation = CGPointZero
        dragAllowed = false
        currentPipeCheckpointCounter = 0
        
        if pipeTip != nil {
            pipeTip!.removeFromParent()
            pipeTipLinkPath = CGPathCreateMutable()
            pipeTipLinkShapeNode.path = pipeTipLinkPath
        }
        
        if (timer != nil) {
            timer?.invalidate()
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
            if pipeCheckpoint.order == 0 {
                currentPipeCheckpoint = SKSpriteNode(texture: createPipeCheckpointTexture())
                currentPipeCheckpoint!.position = pointForColumn(pipeCheckpoint.tile.column, row: pipeCheckpoint.tile.row)
                pipesLayer.addChild(currentPipeCheckpoint!)
            }
        }
        
        pipeTipLinkShapeNode.lineWidth = tileSize/1.5
        pipeTipLinkShapeNode.strokeColor = currentLevel.color
        pipesLayer.addChild(pipeTipLinkShapeNode)
    }
    
    func setupLevelPreview() {
        
        if levelPreviewLayer.children.count > 0 {
            levelPreviewLayer.removeAllChildren()
        }
        
        var prevPipeCheckpoint: PipeCheckpoint? = nil
        let sortedPipeCheckpoints = currentLevel.pipeCheckpoints.sort({ $0.order < $1.order })

        for (idx, pipeCheckpoint) in sortedPipeCheckpoints.enumerate() {
            if idx > 0 {
                prevPipeCheckpoint = sortedPipeCheckpoints[idx-1]
            }
            
            let pipeCheckpointSprite = SKSpriteNode(texture: createPipeCheckpointTexture())
            pipeCheckpointSprite.position = pointForColumn(pipeCheckpoint.tile.column, row: pipeCheckpoint.tile.row)
            levelPreviewLayer.addChild(pipeCheckpointSprite)
            
            if prevPipeCheckpoint != nil {
                
                let prevPipeCheckpointPosition = pointForColumn(prevPipeCheckpoint!.tile.column, row: prevPipeCheckpoint!.tile.row)
                
                let pipePath = CGPathCreateMutable()
                CGPathMoveToPoint(pipePath, nil, prevPipeCheckpointPosition.x, prevPipeCheckpointPosition.y)
                CGPathAddLineToPoint(pipePath, nil, pipeCheckpointSprite.position.x, pipeCheckpointSprite.position.y)
                
                let pipeShapeNode = SKShapeNode(path: pipePath)
                pipeShapeNode.lineWidth = tileSize/1.5
                pipeShapeNode.strokeColor = currentLevel.color
                levelPreviewLayer.addChild(pipeShapeNode)
            }
        }
    }
    
    func createPipeTipLinkPath() {
        
        pipeTipLinkPath = CGPathCreateMutable()
        CGPathMoveToPoint(pipeTipLinkPath, nil, currentPipeCheckpoint!.position.x, currentPipeCheckpoint!.position.y)
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
                let evenColor = currentLevel.color
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
        CGContextSetFillColorWithColor(ctx, currentLevel.color.CGColor)
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
