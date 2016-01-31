//
//  Level.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright © 2016 tec. All rights reserved.
//

import Foundation
import UIKit

class Level {
    
    var orderMap: [ UnicodeScalar: Int ] {
        return [
            "0": 0,
            "1": 1,
            "2": 2,
            "3": 3,
            "4": 4,
            "5": 5,
            "6": 6,
            "7": 7,
            "8": 8,
            "9": 9,
            "⃐": 0,
            "⃑": 1,
            "⃒": 2,
            "⃓": 3,
            "⃔": 4,
            "⃕": 5,
            "⃖": 6,
            "⃗": 7,
            "⃘": 8,
            "⃙": 9,
        ]
    }
    var idx: Int = 0
    var color: UIColor = UIColor.clearColor()
    
    var colsCount: Int = 0
    var rowsCount: Int = 0
    
    var pipeCheckpoints: [PipeCheckpoint] = []
    
    init(idx: Int) {
        
        self.idx = idx
        self.loadCurrentLevel()
    }
    
    private func loadCurrentLevel() {
        
        let fileName: String = getFileName(idx)
        
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") {
            
            let data: String?
            do {
                data = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            } catch {
                data = nil
            }
            
            if let content = (data) {
                let rows = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                
                rowsCount = rows.count
                
                for (rowIdx, row) in rows.enumerate() {
                    
                    let rowCharacters = row.characters
                    
                    if rowIdx == 0 {
                        colsCount = rowCharacters.count
                    }
                    
                    let tileRow = rowsCount - rowIdx - 1
                    
                    for (column, value) in row.characters.enumerate() {
                        if (value != ".") {
                            
                            let strValue = "\(value)"
                            
                            if strValue.unicodeScalars.count > 1 {
                                
                                for scalar in strValue.unicodeScalars {
                                    
                                    pipeCheckpoints.append(PipeCheckpoint(tile: Tile2D(column: column, row: tileRow), order: orderMap[scalar]!))
                                }
                                
                            } else {
                            
                                pipeCheckpoints.append(PipeCheckpoint(tile: Tile2D(column: column, row: tileRow), order: Int("\(value)")!))
                            }
                        }
                    }
                }
            }
            
            switch idx {
            case 1:
                color = UIColor(255, 0, 240) // magenta
                break
            case 2:
                color = UIColor(252, 255, 0) // yellow
                break
            case 3:
                color = UIColor(red: 0.922, green: 0, blue: 0, alpha: 1) // red
                break
            case 4:
                color = UIColor(30, 255, 0) // green
                break
            default:
                break
            }
        } else {
            print("Level error! Level does not exist.")
        }
    }
    
    private func getFileName(level: Int) -> String {
        return "level-" + String(level)
    }
}
