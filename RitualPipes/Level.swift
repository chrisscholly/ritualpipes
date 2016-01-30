//
//  Level.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright © 2016 tec. All rights reserved.
//

import Foundation

class Level {
    
    var idx: Int = 0
    
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
                            pipeCheckpoints.append(PipeCheckpoint(tile: Tile2D(column: column, row: tileRow), order: Int("\(value)")!))
                        }
                    }
                }
            }
        } else {
            print("Level error! Level does not exist.")
        }
    }
    
    private func getFileName(level: Int) -> String {
        return "level-" + String(level)
    }
}
