//
//  GameSubControlsView.swift
//  TheGrid
//
//  Created by Valérie Taesch on 31/03/2015.
//  Copyright (c) 2015 kicody. All rights reserved.
//

import UIKit

class GameSubControlsView : UIView {
    
    var goalButton: UIButton = UIButton()
    var displayGoalButton: Bool = true {
        didSet {
            if displayGoalButton {
                self.addSubview(goalButton)
            } else {
                goalButton.removeFromSuperview()
            }
        }
    }
    
    private var buttonSize: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        self.backgroundColor = UIColor.clearColor()
    
        buttonSize = (bounds.width / 10).normalizePixelPerfect()
        initGoalButton()
    }
    
    func initGoalButton() {
        self.addSubview(goalButton)
        goalButton.addSubview(TargetIconView(size: buttonSize!, color: UIColor.whiteColor()))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutGoalButton()
    }
    
    func layoutGoalButton() {
        let x = bounds.width - buttonSize! - 20
        goalButton.frame = CGRectMake(x, 20, buttonSize!, buttonSize!)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let width = bounds.width
        let height = buttonSize!
        let heightMargin: CGFloat = 2 * 20
        return CGSizeMake(width, height + heightMargin)
    }
}
