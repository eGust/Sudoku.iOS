
//
//  SudokuController.swift
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

import Foundation
import SpriteKit

class GameController {
    let model = GameModel(), iNone = 0, iHigh = 1, iSel = 2
    var tiles: [TileView?], resources: Resources, lastTouched: TileView? = nil
    
    init(res: Resources!) {
        tiles = []
        resources = res
        for i in 0..<90 {
            tiles.append(nil)
        }
    }
    
    func startNewGame() {
        model.newGame(level: 1)
        
        var dcnt = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for i in 0..<81 {
            if let t = tiles[i] {
                let dInit = model.initial.TileAtIndex(i)
                if dInit == 0 {
                    t.type = 0
                    t.status = 0
                    t.digit = model.final.TileAtIndex(i)
                } else {
                    t.type = 2
                    t.status = 0
                    t.digit = dInit
                    dcnt[dInit-1] += 1
                }
                t.update()
            }
        }
        
        for i in 81..<90 {
            if let t = tiles[i] {
                t.row = dcnt[i-81]
                t.status = t.row == 9 ? 1 : 0
                t.update()
            }
        }
    }
    
    func initTile(index: Int, btn: SKSpriteNode!, lbl: SKLabelNode) -> TileView
    {
        if tiles[index] == nil {
            let r = TileView(btn: btn, lbl: lbl, res: resources, idx: index)
            tiles[index] = r
            return r
        }
        return tiles[index]!
    }
    
    func findInRange(p: CGPoint) -> TileView? {
        for i in 0..<90 {
            if let t = tiles[i] {
                if t.button.containsPoint(p) {
                    //NSLog("button[\(t.index)].location: \(t.button.frame)")
                    return t
                }
            }
        }
        return nil;
    }
    
    func resetStatus() {
        for i in 0..<81 {
            tiles[i]?.setStatus(iNone)
        }
        
        for i in 81..<90 {
            if let t = tiles[i] {
                t.setStatus(t.row==9 ? iHigh : iNone)
            }
        }
    }
    
    func highlightRelative(idx: Int) {
        for i in OSudokuData.Relatives(idx) {
            tiles[(i as NSNumber).integerValue]?.setStatus(iHigh)
        }
    }
    
    func highlightDigit(d: Int) {
        for i in 0..<81 {
            if let t = tiles[i] {
                if t.digit == d && t.type != 0 {
                    t.setStatus(iHigh)
                }
            }
        }
    }
    
    func onTouchButton(tile: TileView!) {
        resetStatus()
        
        if let last = lastTouched {
            if last === tile {
                lastTouched = nil
                return
            }
            
            if last.isTile() && last.type == 0 {
                if last.digit == tile.digit {
                    // correct!
                    tile.row += 1
                    if tile.row != 9 {
                        highlightDigit(tile.digit)
                    }
                    tile.update()
                    last.setType(1)
                    lastTouched = nil
                } else {
                    // play error animation
                    last.setStatus(iSel)
                }
                return
            }
        }
        
        if tile.row == 9 {
            return;
        }
        
        highlightDigit(tile.digit)
        tile.setStatus(iSel)
        lastTouched = tile
    }
    
    func onTouchTile(tile: TileView!) {
        resetStatus()
        
        if let last = lastTouched {
            if last === tile {
                lastTouched = nil
                return
            }
        }
        
        if tile.type == 0 {
            highlightRelative(tile.index)
        } else {
            highlightDigit(tile.digit)
        }
        tile.setStatus(iSel)
        lastTouched = tile
    }
    
    func handleTouch(p: CGPoint) -> Bool {
        if let t = findInRange(p) {
            if t.index >= 81 {
                onTouchButton(t)
            } else {
                onTouchTile(t)
            }
            return true
        }
        return false
    }
}

class TileView {
    var button: SKSpriteNode!, label: SKLabelNode!, resources: Resources!, labelCount: SKLabelNode? = nil,
    type = 0, status = 0, digit = 0, index = 0, row = 0, col = 0
    
    /*
    * type
    *   0: empty
    *   1: fill
    *   2: given
    *   3: button
    *
    * status
    *   0: normal
    *   1: highlight / disable
    *   2: selected
    */
    
    init(btn: SKSpriteNode!, lbl: SKLabelNode, res: Resources!, idx: Int)
    {
        resources = res
        button = btn
        label = lbl
        index = idx
        update()
    }
    
    func update() {
        label.text = "\(digit)"
        label.hidden = type == 0
        if type == 3 {
            labelCount?.text = "\(row)"
            button.texture = row == 9 ? resources.buttons[9 + 1] : resources.buttons[9 + status]
        } else {
            button.texture = resources.buttons[type*3 + status]
        }
    }
    
    func setType(v: Int) {
        if type != v {
            type = v
            update()
        }
    }
    
    func setStatus(v: Int) {
        if status != v {
            status = v
            update()
        }
    }
    
    func setDigit(v: Int) {
        if digit != v {
            digit = v
            update()
        }
    }
    
    func isTile() -> Bool {
        return type != 3;
    }
    
    func isButton() -> Bool {
        return type == 3;
    }
}
