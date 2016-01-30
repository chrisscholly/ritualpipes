//
//  PipeCheckpoint.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright © 2016 tec. All rights reserved.
//

import Foundation

struct PipeCheckpoint {
    
    var tile: Tile2D,
    order: Int
    
    init(tile: Tile2D, order: Int) {
        self.tile = tile
        self.order = order
    }
}
