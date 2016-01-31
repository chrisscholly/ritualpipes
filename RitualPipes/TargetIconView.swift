//
//  TargetIconView.swift
//  TheGrid
//
//  Created by Christophe Scholly on 31/03/2015.
//  Copyright (c) 2015 kicody. All rights reserved.
//

import UIKit

class TargetIconView: TGIconView {
    
    override func drawRect(rect: CGRect) {
        TGStyleKit.drawTargetIcon(iconColor: self.color, size: self.size)
    }
}
