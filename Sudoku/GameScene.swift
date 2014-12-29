//
//  GameScene.swift
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

import SpriteKit

class Resources {
    var buttons, frames: [SKTexture]
    
    init() {
        buttons = []
        let btnRes = SKTexture(imageNamed: "buttons")
        , imgWidth = btnRes.size().width
        , imgHeight = btnRes.size().height
        , btnSize = imgHeight - 2
        , yFrom = 1.0 / imgHeight
        , ySize = (imgHeight - 2) / imgHeight
        , btnW = (1.0+btnSize) / imgWidth
        , xSize = btnSize / imgWidth
        
        var x = 1.0/imgWidth
        for i in 0..<12 {
            buttons.append(SKTexture(
                rect: CGRect(x: x, y: yFrom, width: xSize, height: ySize),
                inTexture: btnRes
                ))
            x += btnW
        }
        
        let frmRes = SKTexture(imageNamed: "frames")
        frames = [
            SKTexture(rect: CGRect(x: 0, y: 0, width: 0.5, height: 1), inTexture: frmRes),
            SKTexture(rect: CGRect(x: 0.5, y: 0, width: 0.5, height: 1), inTexture: frmRes),
        ]
        //NSLog("FrameSize:\(frmRes.size())")
        //NSLog("FrameSize:\(frames[0].size())")
    }
}

class GameScene: SKScene {
    var imgScale = CGFloat(), imgBaseOffset = CGFloat()
    , gamer: GameController? = nil, btnStart: SKLabelNode? = nil
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.size = UIScreen.mainScreen().bounds.size
        
        let res = Resources()
        , W = Int(self.frame.size.width)
        , H = Int(self.frame.size.height)
        , buttonSize = W * 3 / 32
        , borderSize = (W / 100)
        , bgSize = buttonSize * 9 + borderSize * 12
        , blankSize = (W - bgSize) / 2
        , frameSize = buttonSize * 3 + borderSize * 4
        , xCenter = CGRectGetMidX(self.frame)
        , yCenter = CGRectGetMidY(self.frame)
        , gcer = GameController(res: res)
        , bg = SKShapeNode(rectOfSize: CGSize(width: bgSize+1, height: bgSize+1))
        , frmColor1 = UIColor(red: 0, green: 0, blue: 0.3, alpha: 1)
        , frmColor2 = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        
        bg.fillColor = frmColor1
        bg.strokeColor = UIColor.whiteColor()
        bg.antialiased = true
        bg.lineWidth = 0.5
        bg.position = CGPoint(x: xCenter, y: yCenter + CGFloat(frameSize/2))
        bg.zPosition = -1.0
        //bg.anchorPoint = CGPoint(x: 0, y: 0);
        for r in 0..<3 {
            for c in 0..<3 {
                if (r+c) & 1 == 0 {
                    continue
                }
                let frm = SKShapeNode(rectOfSize: CGSize(width: frameSize, height: frameSize))
                frm.fillColor = frmColor2
                frm.position = CGPoint(x: (c-1) * frameSize, y: (r-1) * frameSize)
                frm.lineWidth = 0
                bg.addChild(frm)
            }
        }
        self.addChild(bg)
        
        let scaleButton = CGFloat(buttonSize) / res.buttons[0].size().width
        , tileSize = CGFloat(buttonSize + borderSize)
        , X0 = xCenter - tileSize*4 - CGFloat(borderSize)
        , Y0 = yCenter + CGFloat(frameSize/2-borderSize) - tileSize*4
        , fontSize = CGFloat(buttonSize)*0.7
        
        // create tiles
        for row in 0..<9 {
            for col in 0..<9 {
                let btn = SKSpriteNode(color: UIColor.redColor(), size: res.buttons[0].size())
                btn.texture = res.buttons[(col+row)%10]
                btn.setScale(scaleButton)
                btn.position = CGPoint(
                    x: X0 + CGFloat(col)*tileSize + CGFloat(col/3*borderSize),
                    y: Y0 + CGFloat(row)*tileSize + CGFloat(row/3*borderSize) )
                self.addChild(btn)
                
                let label = SKLabelNode(text: "1")
                //label.hidden = true
                label.fontName = "AmericanTypewriter-Bold"
                label.fontSize = fontSize
                label.fontColor = UIColor.redColor()
                label.position = CGPoint(
                    x: X0 + CGFloat(col)*tileSize + CGFloat(col/3*borderSize),
                    y: Y0 + CGFloat(row)*tileSize + CGFloat(row/3*borderSize) - fontSize*0.35 )
                self.addChild(label)
                
                //*
                let t = gcer.initTile(row*9+col, btn: btn, lbl: label)
                t.col = col
                t.row = row
                //*/
            }
        }
        
        // create buttons
        for col in 0..<9 {
            let btn = SKSpriteNode(color: UIColor.redColor(), size: res.buttons[0].size())
            btn.setScale(scaleButton*1.05)
            btn.position = CGPoint(
                x: X0 + CGFloat(col)*tileSize + CGFloat(col/3*borderSize),
                y: Y0 - 1.618*tileSize )
            btn.texture = res.buttons[1]
            //btn.zPosition = 1.0
            self.addChild(btn)
            
            let label = SKLabelNode(text: "1"), lblcnt = SKLabelNode(text: "?")
            
            label.fontName = "AmericanTypewriter-Bold"
            label.fontSize = fontSize
            label.fontColor = UIColor.redColor()
            label.position = CGPoint(
                x: X0 + CGFloat(col)*tileSize + CGFloat(col/3*borderSize),
                y: Y0 - 1.618*tileSize - fontSize*0.35 )
            self.addChild(label)
            
            lblcnt.fontName = "AmericanTypewriter"
            lblcnt.fontSize = fontSize*0.4
            lblcnt.fontColor = UIColor.blueColor()
            lblcnt.position = CGPoint(
                x: X0 + CGFloat(col)*tileSize + CGFloat(col/3*borderSize) + lblcnt.frame.width*1.1,
                y: Y0 - tileSize - fontSize*0.65 )
            self.addChild(lblcnt)
            
            let t = gcer.initTile(81+col, btn: btn, lbl: label)
            t.setDigit(col+1)
            t.setType(3)
            t.col = col+1
            t.row = -1
            t.labelCount = lblcnt
        }
        
        // add start game button
        let btnStart = SKLabelNode(text: "Start")
        btnStart.fontSize = fontSize*0.7
        btnStart.position = CGPoint(
            x: xCenter*0.618,
            y: Y0 - 1.618*tileSize*2 )
        btnStart.fontColor = UIColor.blueColor()
        btnStart.zPosition = 2.0
        self.addChild(btnStart)
        
        self.btnStart = btnStart
        gamer = gcer
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if let g = gamer {
            if let bs = btnStart {
                for touch: AnyObject in touches {
                    let location = touch.locationInNode(self)
                    if bs.containsPoint(location) {
                        g.startNewGame()
                        break
                    }
                    if g.handleTouch(location) {
                        break
                    }
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
