//
//  StarsRatingView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 12/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class StarsRatingView: UIControl {

    // MARK: - Properties
    
    private(set) var value: CGFloat = 0
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 5
    private let spacing: CGFloat = 0.5
    private let continuous = true
    
    var shouldBecomeFirstResponder = false
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isExclusiveTouch = true
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        self.setNeedsDisplay()
    }
        
    // MARK: - Shape Drawing
    
    private func drawStarShape(frame: CGRect, tintColor: UIColor, highlighted: Bool) {
        self.drawAccurateHalfStarShape(frame: frame, tintColor: tintColor, progress: highlighted ? 1 : 0)
    }
    
    private func drawAccurateHalfStarShape(frame: CGRect, tintColor: UIColor, progress: CGFloat) {
        let starShapePath = UIBezierPath()
        starShapePath.move(to: CGPoint(x: frame.minX + 0.62723 * frame.width, y: frame.minY + 0.37309 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.02500 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.37292 * frame.width, y: frame.minY + 0.37309 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.02500 * frame.width, y: frame.minY + 0.39112 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.30504 * frame.width, y: frame.minY + 0.62908 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.20642 * frame.width, y: frame.minY + 0.97500 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.78265 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.79358 * frame.width, y: frame.minY + 0.97500 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.69501 * frame.width, y: frame.minY + 0.62908 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.97500 * frame.width, y: frame.minY + 0.39112 * frame.height))
        starShapePath.addLine(to: CGPoint(x: frame.minX + 0.62723 * frame.width, y: frame.minY + 0.37309 * frame.height))
        starShapePath.close()
        starShapePath.miterLimit = 4
        
        let frameWidth = frame.width
        let rightRectOfStar = CGRect(x: frame.origin.x + progress * frameWidth, y: frame.origin.y, width: frameWidth - progress * frameWidth, height: frame.height)
        let clipPath = UIBezierPath(rect: CGRect.infinite)
        clipPath.append(UIBezierPath(rect: rightRectOfStar))
        clipPath.usesEvenOddFillRule = true
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        clipPath.addClip()
        tintColor.setFill()
        starShapePath.fill()
        context?.restoreGState()
        
        tintColor.setStroke()
        starShapePath.lineWidth = 1
        starShapePath.stroke()
    }
        
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.backgroundColor!.cgColor)
        context?.fill(rect)
        
        let availableWidth = rect.width - (self.spacing * (self.maximumValue - 1)) - 2
        let cellWidth = availableWidth / self.maximumValue
        let starSide = (cellWidth <= rect.height) ? cellWidth : rect.height
        for idx in 0..<Int(self.maximumValue) {
            let idx = CGFloat(idx)
            let centerX = cellWidth * idx + cellWidth / 2 + self.spacing * idx + 1
            let center = CGPoint(x: centerX, y: rect.height / 2)
            let frame = CGRect(x: centerX - starSide / 2, y: center.y - starSide / 2, width: starSide, height: starSide)
            let highlighted = Float(idx + 1) <= ceilf(Float(self.value))
            self.drawStarShape(frame: frame, tintColor: self.tintColor, highlighted: highlighted)
        }
    }
        
    // MARK: - Touches
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if self.isEnabled {
            super.beginTracking(touch, with: event)
            if self.shouldBecomeFirstResponder, !self.isFirstResponder {
                self.becomeFirstResponder()
            }
            self.handleTouch(touch)
            return true
        }
        return false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if self.isEnabled {
            super.continueTracking(touch, with: event)
            self.handleTouch(touch)
            return true
        }
        return false
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if self.shouldBecomeFirstResponder, self.isFirstResponder {
            self.resignFirstResponder()
        }
        self.handleTouch(touch)
        if !self.continuous {
            self.sendActions(for: .valueChanged)
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        if self.shouldBecomeFirstResponder, self.isFirstResponder {
            self.resignFirstResponder()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self {
            return !self.isUserInteractionEnabled
        }
        return false
    }
    
    private func handleTouch(_ touch: UITouch?) {
        guard let touch = touch else {
            return
        }
        
        let cellWidth = self.bounds.width / self.maximumValue
        let location = touch.location(in: self)
        let value = ceilf(Float(location.x / cellWidth))
        self.setValue(CGFloat(value), sendAction: self.continuous)
    }
    
    func setValue(_ value: CGFloat) {
        self.setValue(value, sendAction: false)
    }
    
    private func setValue(_ value: CGFloat, sendAction: Bool) {
        if value >= self.minimumValue, value <= self.maximumValue {
            self.value = value
            if sendAction {
                self.sendActions(for: .valueChanged)
            }
            self.setNeedsDisplay()
        }
    }
        
    // MARK: - First responder
    
    override var canBecomeFirstResponder: Bool {
        return self.shouldBecomeFirstResponder
    }
        
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        let height: CGFloat = 44
        return CGSize(width: self.maximumValue * height + (self.maximumValue - 1) * self.spacing, height: height)
    }
    
}

