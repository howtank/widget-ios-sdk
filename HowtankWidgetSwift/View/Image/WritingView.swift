//
//  WritingView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 01/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class WritingView: UIView {    
    // MARK: - Properties
    
    var firstBullet: UIView?
    var secondBullet: UIView?
    var thirdBullet: UIView?
    
    private var bulletColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1)
    
    private var bulletSize: CGFloat = 0
    private var initialBulletTop: CGFloat = 0
    
    private var animating = false
        
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.drawUI()
        self.animate()
    }

    func setBulletColor(color: UIColor) {
        self.bulletColor = color
        
        firstBullet?.backgroundColor = color
        secondBullet?.backgroundColor = color
        thirdBullet?.backgroundColor = color
    }
    
    private func drawUI() {
        let frameWidth = self.frame.width
        self.bulletSize = frameWidth / 6
        self.initialBulletTop = (self.frame.height - self.bulletSize) / 2
        let bulletSpacing = self.bulletSize * 0.5
        let totalWidth = self.bulletSize * 3 + bulletSpacing * 2
        let startOffset = (frameWidth - totalWidth) / 2
        
        self.firstBullet = UIView(frame: CGRect(x: startOffset, y: self.initialBulletTop, width: self.bulletSize, height: self.bulletSize))
        self.secondBullet = UIView(frame: CGRect(x: startOffset + self.bulletSize + bulletSpacing, y: self.initialBulletTop, width: self.bulletSize, height: self.bulletSize))
        self.thirdBullet = UIView(frame: CGRect(x: startOffset + (self.bulletSize + bulletSpacing) * 2, y: self.initialBulletTop, width: self.bulletSize, height: self.bulletSize))
        
        self.firstBullet?.layer.cornerRadius = self.bulletSize / 2
        self.secondBullet?.layer.cornerRadius = self.bulletSize / 2
        self.thirdBullet?.layer.cornerRadius = self.bulletSize / 2
        self.firstBullet?.backgroundColor = self.bulletColor
        self.secondBullet?.backgroundColor = self.bulletColor
        self.thirdBullet?.backgroundColor = self.bulletColor
        
        self.addSubview(self.firstBullet!)
        self.addSubview(self.secondBullet!)
        self.addSubview(self.thirdBullet!)
    }
    
    private func animate() {
        if self.isHidden {
            return
        }
        self.animating = true
        
        Utility.delay(1) {
            self.animateBullet(self.firstBullet)
        }
        Utility.delay(1.15) {
            self.animateBullet(self.secondBullet)
        }
        Utility.delay(1.3) {
            self.animateBullet(self.thirdBullet)
        }
        Utility.delay(3) {
            self.animate()
        }
    }
    
    private func animateBullet(_ bulletView: UIView?) {
        if let bulletView = bulletView {
            UIView.animate(withDuration: 0.3, animations: {
                bulletView.frame = CGRect(x: bulletView.frame.origin.x, y: self.initialBulletTop - self.bulletSize * 1.2, width: bulletView.frame.width, height: bulletView.frame.height)
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.3, animations: {
                    bulletView.frame = CGRect(x: bulletView.frame.origin.x, y: self.initialBulletTop, width: bulletView.frame.width, height: bulletView.frame.height)
                })
            })
        }
    }

}
