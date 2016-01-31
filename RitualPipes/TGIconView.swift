//
//  TGIconView.swift
//  TheGrid
//
//  Created by Christophe Scholly on 17/03/2015.
//  Copyright (c) 2015 kicody. All rights reserved.
//

import UIKit

class TGIconView: UIView {
    
    var size: CGFloat
    var color: UIColor
    
    init(size: CGFloat, color: UIColor) {
        self.size = size
        self.color = color
        super.init(frame: CGRectMake(0, 0, size, size))
        
        initialize()
    }
    
    init(size: CGFloat) {
        self.size = size
        self.color = UIColor.clearColor()
        super.init(frame: CGRectMake(0, 0, size, size))
        
        initialize()
    }
    
    func initialize() {
        self.opaque = false
        self.userInteractionEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
