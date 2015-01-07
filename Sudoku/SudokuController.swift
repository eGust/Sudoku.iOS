
//
//  SudokuController.swift
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014 Chen Xi. All rights reserved.
//

import Foundation
import SpriteKit

class GameController {
    let model = GameModel(), iNone = 0, iHigh = 1, iSel = 2
    var tiles: [TileView?]
    , resources: Resources
    , lastTouched: TileView? = nil
    , status: GameStatus!
    
    init(res: Resources!, stat: GameStatus!) {
        tiles = []
        resources = res
        status = stat
        for i in 0..<90 {
            tiles.append(nil)
        }
    }
    
    func startNewGame() {
        model.newGame(level: 1)
        lastTouched = nil
        
        var dcnt = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for i in 0..<81 {
            if let t = tiles[i] {
                let dInit = model.initial.TileAtIndex(i)
                if dInit == 0 {
                    t.type = 0
                    t.given = false
                    t.status = 0
                    t.digit = model.final.TileAtIndex(i)
                } else {
                    t.type = 1
                    t.given = true
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
        status.reset()
        status.update()
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
    
    func getFullScore(#row: Int, col: Int) -> Int {
        let mtxRowBase = row / 3 * 3, mtxColBase = col / 3 * 3
        var rMsk = 0, cMsk = 0, mMsk = 0
        for i in 0..<9 {
            let mr = mtxRowBase + i/3, mc = mtxColBase + i%3
            
            if let t = tiles[row*9+i] {
                if t.type != 0 {
                    rMsk |= 1 << (t.digit-1)
                }
            }
            
            if let t = tiles[i*9+col] {
                if t.type != 0 {
                    cMsk |= 1 << (t.digit-1)
                }
            }
            
            if let t = tiles[mr*9+mc] {
                if t.type != 0 {
                    mMsk |= 1 << (t.digit-1)
                }
            }
        }
        
        var r = (rMsk == 0x01FF ? 1 : 0) + (cMsk == 0x01FF ? 1 : 0) + (mMsk == 0x01FF ? 1 : 0)
        if r == 0 {
            return 0
        }
        return 1 << (r-1)
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
                    var score = 1
                    if tile.row != 9 {
                        highlightDigit(tile.digit)
                        last.setStatus(iSel)
                    } else {
                        score = 5
                    }
                    
                    tile.update()
                    last.setType(1)
                    lastTouched = nil
                    
                    score += getFullScore(row: last.row, col: last.col) * 10
                    status.addScore(score)
               } else {
                    // play error animation
                    last.setStatus(iSel)
                    status.wrong++
                    status.addScore(-3)
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
    var button: SKSpriteNode!, label: SKLabelNode!, resources: Resources!,
    labelCount: SKLabelNode? = nil,
    type = 0, status = 0, digit = 0, index = 0, row = 0, col = 0, given = false
    
    /*
    * type
    *   0: empty
    *   1: fill
    *   3: button
    *
    * status
    *   0: normal
    *   1: highlight / disable
    *   2: selected
    */
    
    init(btn: SKSpriteNode!, lbl: SKLabelNode!, res: Resources!, idx: Int)
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
        if type == 2 {
            labelCount?.text = "\(row)"
            label.fontColor = UIColor.redColor()
            button.texture = row == 9 ? resources.buttons[6 + 1] : resources.buttons[6 + status]
        } else {
            button.texture = resources.buttons[type*3 + status]
            label.fontColor = given ? UIColor.blackColor() : UIColor.whiteColor()
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
    
    func setGiven(v: Bool) {
        if given != v {
            given = v
            update()
        }
    }
    
    func isTile() -> Bool {
        return type != 3
    }
    
    func isButton() -> Bool {
        return type == 3
    }
}

class GameStatus {
    var lblTime: SKLabelNode!, lblScore: SKLabelNode!, lblWrong: SKLabelNode!
    , score = 0, wrong = 0, seconds = 0, startTime = NSDate.timeIntervalSinceReferenceDate(), paused = true
    , lastScore = 0, lastWrong = 0, lastSeconds = 0, baseSeconds = 0.0, scoreTimes: Float = 10.0
    
    init(Time: SKLabelNode!, Score: SKLabelNode!, Wrong: SKLabelNode!) {
        lblTime = Time
        lblScore = Score
        lblWrong = Wrong
    }
    
    func reset() {
        score = 0
        wrong = 0
        seconds = 0
        baseSeconds = 0
        startTime = NSDate.timeIntervalSinceReferenceDate()
        paused = false
    }
    
    func pause() {
        paused = true
        baseSeconds += NSDate.timeIntervalSinceReferenceDate() - startTime
        lastSeconds = 0
    }
    
    func resume() {
        startTime = NSDate.timeIntervalSinceReferenceDate()
        paused = false
    }
    
    func addScore(s: Int) {
        score += Int(Float(s)*scoreTimes/(0.4+0.1*Float(lastSeconds / 30)))
    }
    
    func update() {
        if paused {
            return
        }
        
        if lastScore != score {
            lblScore.text = String(format: "SCORE: %05d", score > 0 ? score : 0)
            lastScore = score
        }

        if lastWrong != wrong {
            lblWrong.text = String(format: "WRONG: %02d", wrong)
            lastWrong = wrong
        }

        seconds = Int(NSDate.timeIntervalSinceReferenceDate() - startTime + baseSeconds)
        if lastSeconds != seconds {
            let min = seconds / 60, sec = seconds % 60
            lblTime.text = String(format: "%02d:%02d", min, sec)
            lastSeconds = seconds
        }
    }
}
