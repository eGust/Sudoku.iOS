//
//  SudokuModel.swift
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

import Foundation

class GameModel {
    var initial, final: OSudokuData
    var running = false
    
    init() {
        initial = OSudokuData.Generate()
        final = initial.copy() as OSudokuData
    }
    
    func newGame(level: Int = 0) {
        let g = OSudokuData.Generate(), c = g.Cross()
        var initialCount = Int(arc4random_uniform(5))
        switch (level) {
        case 1: // easy
            initialCount += 38;
        case 2: // medium
            initialCount += 33;
        case 3: // hard
            initialCount += 28;
        default: // very hard
            initialCount = 0;
        }
        
        while (c.GivenCount < initialCount) {
            var r = Int(arc4random_uniform(81))
            if (c.TileAtIndex(r) == 0) {
                c.setTileAtIndex(r, withValue: g.TileAtIndex(r))
            }
        }
        
        final = g
        initial = c
        running = true
    }
    
    func setTile(#row: Int, col: Int, val: Int) -> Bool {
        if (!running) || initial.TileAtRow(row, andColumn: col) != val {
            return false
        }
        return true
    }
    
    func isInitialTile(#row: Int, col: Int) -> Bool {
        return initial.TileAtRow(row, andColumn: col) != 0
    }
}
