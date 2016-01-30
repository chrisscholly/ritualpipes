//
//  Tile2D.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright © 2016 tec. All rights reserved.
//

struct Tile2D {
    
    var column: Int,
    row: Int
    
    init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}

extension Tile2D: Equatable {}

func ==(lhs: Tile2D, rhs: Tile2D) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
