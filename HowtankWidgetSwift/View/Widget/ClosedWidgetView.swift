//
//  ClosedWidgetView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol ClosedWidgetViewDelegate {
    func widgetShouldExpand()
    func shouldDisableWidget(completion: @escaping (Bool) -> Void)
    func widgetShouldBeRedrawn()
}

class ClosedWidgetView: UIView {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var writingView: WritingView!
        
    // MARK: - Properties
    
    var delegate: ClosedWidgetViewDelegate?
    
    var chatStarted = false {
        didSet {
            self.setBackgroundColor()
        }
    }
    
    private var previousWindowWidth: CGFloat = 0
    
    private var containerFrame: CGRect?
    private var originalSize = CGPoint.zero
    private var originalFrame = CGRect.zero
    
    private var closeAreaView: UIView?
    private var closeAreaBackgroundView: UIView?
    
    private var expandedMode = false
    
    private var animator: UIDynamicAnimator?
    private var paneBehavior: PaneBehavior?
    private var closeAreaTimer: Timer?
    
    private var newMessagesCount = 0

    // Intersection
    private var intersectRect: CGRect?
    private var closeAreaFullyDisplayed = false
    private var intersectsWithCloseView = false
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        previousWindowWidth = self.window?.frame.size.width ?? 0
        
        // Init view
        self.counterLabel.alpha = 0
        self.counterLabel.textColor = Theme.shared.color(.active)
        self.writingView.alpha = 0
        
        // Make rounded corners
        self.originalSize = CGPoint(x: self.frame.width, y: self.frame.height)
        self.layer.cornerRadius = self.originalSize.x / 2
        
        self.setBackgroundColor()
        
        // Gesture recognizers
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chatButtonClicked(sender:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panButton(sender:))))
    }
    
    private func setBackgroundColor() {
        let theme = Theme.shared
        self.backgroundColor = self.expandedMode ? theme.color(.bubbleInactive) : (self.chatStarted ? theme.color(.bubbleActive) : theme.color(.bubbleInactive))
        
        self.chatImageView.image = self.chatStarted ? theme.activeChatImage : theme.inactiveChatImage
        self.chatImageView.tintColor = self.chatStarted ? theme.color(.bubbleActiveText) : theme.color(.bubbleInactiveText)
    }
    
    override func layoutSubviews() {
        let shouldRefresh = self.previousWindowWidth != self.window!.frame.width
        self.previousWindowWidth = self.window!.frame.width
        
        if shouldRefresh {
            self.delegate?.widgetShouldBeRedrawn()
        }
        super.layoutSubviews()
    }
        
    // MARK: - Configuration
    
    func configure(containerView: UIView, closeAreaView: UIView, closeAreaBackgroundView: UIView) {
        if #available(iOS 11.0, *) {
            self.containerFrame = containerView.safeAreaLayoutGuide.layoutFrame
            // Special case for other iPhones than X
            if containerFrame?.origin.y == 0 {
                self.containerFrame = CGRect(x: containerFrame!.origin.x, y: Constants.Dimensions.statusBarHeight, width: containerFrame!.width, height: containerFrame!.height - Constants.Dimensions.statusBarHeight)
            }
        } else {
            // Fallback on earlier versions
            self.containerFrame = CGRect(x: 0, y: Constants.Dimensions.statusBarHeight, width: containerView.frame.width, height: containerView.frame.height - Constants.Dimensions.statusBarHeight)
        }
        
        self.closeAreaView = closeAreaView
        self.closeAreaBackgroundView = closeAreaBackgroundView
        
        self.setPosition()
    }
        
    // MARK: - Position and animation
    
    func setPosition() {
        guard let containerFrame = self.containerFrame else {
            return
        }
        
        // Reste any pane behavior
        self.animator?.removeAllBehaviors()
        
        // Handle initial position
        let position = Theme.shared.position()
        
        // X position
        var initialXPosition: CGFloat = 0
        let containerWidth = containerFrame.size.width
        // Check if let position is set
        if !(position.left == "-") {
            // Check wether it's percentage or value
            if position.left.contains("%") {
                let leftPositionValue = position.left.replacingOccurrences(of: "%", with: "").toCGFloat() ?? 0
                initialXPosition = leftPositionValue / 100 * containerWidth
            }
            else {
                initialXPosition = position.left.toCGFloat() ?? 0
            }
        }
        else if !(position.right == "-") {
            // Check wether it's percentage or value
            if position.right.contains("%") {
                let rightPositionValue = position.right.replacingOccurrences(of: "%", with: "").toCGFloat() ?? 0
                initialXPosition = containerFrame.size.width - originalSize.x - rightPositionValue / 100 * containerWidth
            }
            else {
                initialXPosition = containerFrame.size.width - originalSize.x - (position.right.toCGFloat() ?? 0)
            }
        }
        
        // Y position
        var initialYPosition: CGFloat = 0
        let containerHeight = containerFrame.size.height - originalSize.y
        if !(position.top == "-") {
            // Check wether it's percentage or value
            if position.top.contains("%") {
                let topPositionValue = position.top.replacingOccurrences(of: "%", with: "").toCGFloat() ?? 0
                initialYPosition = topPositionValue / 100 * containerHeight + containerFrame.origin.y
            }
            else {
                initialYPosition = (position.top.toCGFloat() ?? 0) + containerFrame.origin.y
            }
        }
        else if !(position.bottom == "-") {
            // Check wether it's percentage or value
            if position.bottom.contains("%") {
                let bottomPositionValue = position.bottom.replacingOccurrences(of: "%", with: "").toCGFloat() ?? 0
                initialYPosition = containerFrame.origin.y + containerFrame.height - originalSize.y - bottomPositionValue / 100 * containerHeight
            }
            else {
                initialYPosition = containerFrame.origin.y + containerFrame.height - originalSize.y - (position.bottom.toCGFloat() ?? 0)
            }
        }
        
        self.frame = CGRect(x: initialXPosition, y: initialYPosition, width: originalSize.y, height: originalSize.y)
    }
    
    
    func showExpandedMode(_ expanded: Bool, fromFrame: CGRect, toFrame: CGRect) {
        self.expandedMode = expanded
        self.frame = fromFrame
        self.isHidden = false
        
        // Remove animator behavior
        animator?.removeAllBehaviors()
        
        if expanded {
            // Reset new messages count
            self.newMessagesCount = 0
            self.counterLabel.alpha = 0
            self.chatImageView.alpha = 0
        }
        
        let animationDuration = expandedMode ? 0.5 : 0.4
        
        // Corner radius animation
        let buttonAnimation = CABasicAnimation(keyPath: "cornerRadius")
        let cornerRadius: CGFloat = expandedMode ? 0 : toFrame.size.height / 2
        buttonAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        buttonAnimation.fromValue = NSNumber(value: Float(self.layer.cornerRadius))
        buttonAnimation.toValue = NSNumber(value: Float(cornerRadius))
        buttonAnimation.duration = animationDuration
        self.layer.cornerRadius = cornerRadius
        self.layer.add(buttonAnimation, forKey: "cornerRadius")
        
        let damping: CGFloat = self.expandedMode ? 0.8 : 1
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: {
            self.frame = toFrame
            self.setBackgroundColor()
            self.counterLabel.alpha = 0
        }) { (completed) in
            if self.expandedMode {
                self.isHidden = true
                // Reset closed view frame
                self.frame = fromFrame
            }
        }
        
        if !self.expandedMode {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .beginFromCurrentState, animations: {
                self.chatImageView.alpha = 1
            }, completion: nil)
        }
    }
    
    private func initOrGetAnimator() -> UIDynamicAnimator? {
        // Animator
        if let superview = self.superview {
            self.animator = UIDynamicAnimator(referenceView: superview)
        }
        return self.animator
    }
    
    // MARK: - Chat
    
    func incrementChatCount() {
        self.newMessagesCount += 1
        self.counterLabel.text = "\(newMessagesCount)"
        UIView.animate(withDuration: 0.4) {
            self.counterLabel.alpha = 1
            self.writingView.alpha = 0
        }
    }
    
    func distantUserWriting(_ writing: Bool) {
        if newMessagesCount == 0 {
            UIView.animate(withDuration: 0.4, animations: {
                self.writingView.alpha = writing ? 1 : 0
            })
        }
    }
        
    // MARK: - Gesture recognizers
    
    @objc func chatButtonClicked(sender: UITapGestureRecognizer) {
        if !self.expandedMode {
            self.delegate?.widgetShouldExpand()
        }
    }
    
    @objc func panButton(sender: UIPanGestureRecognizer) {
        guard let closeAreaView = self.closeAreaView, let superview = self.superview else {
            return
        }
        
        let buttonSize = originalSize.x
        
        if sender.state == .began {
            self.originalFrame = self.frame
            self.animator?.removeAllBehaviors()
            
            // Calculate intersect rect to "stick" view for deletion
            self.intersectRect = CGRect(x: closeAreaView.center.x - buttonSize / 2, y: superview.frame.height - 70 - buttonSize / 2, width: buttonSize, height: buttonSize)
            
            // Timer to display close area view - only when chat is not started
            if !chatStarted {
                self.closeAreaTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(showCloseAreaView), userInfo: nil, repeats: false)
            }
        }
        else if sender.state == .changed {
            if !expandedMode {
                let translation = sender.translation(in: superview)
                let newFrame = CGRect(x: originalFrame.origin.x + translation.x, y: originalFrame.origin.y + translation.y, width: buttonSize, height: buttonSize)
                
                if intersectRect?.intersects(newFrame) ?? false, self.closeAreaFullyDisplayed {
                    let buttonSizeIncrement: CGFloat = 15
                    if !self.intersectsWithCloseView {
                        // Animate
                        let buttonAnimation = CASpringAnimation(keyPath: "cornerRadius")
                        let cornerRadius = (buttonSize + buttonSizeIncrement) / 2
                        buttonAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                        buttonAnimation.fromValue = NSNumber(value: Float(self.layer.cornerRadius))
                        buttonAnimation.toValue = NSNumber(value: Float(cornerRadius))
                        buttonAnimation.duration = 0.4
                        buttonAnimation.damping = 0.5
                        self.closeAreaView?.layer.cornerRadius = cornerRadius
                        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: {
                            self.frame = self.intersectRect!
                            self.closeAreaView?.bounds = CGRect(x: 0, y: 0, width: buttonSize + buttonSizeIncrement, height: buttonSize + buttonSizeIncrement)
                        }, completion: nil)
                    }
                    else {
                        self.frame = intersectRect!
                    }
                    intersectsWithCloseView = true
                }
                else {
                    if self.intersectsWithCloseView {
                        // Animate
                        let buttonAnimation = CASpringAnimation(keyPath: "cornerRadius")
                        let cornerRadius: CGFloat = 45 / 2
                        buttonAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                        buttonAnimation.fromValue = NSNumber(value: Float(self.layer.cornerRadius))
                        buttonAnimation.toValue = NSNumber(value: Float(cornerRadius))
                        buttonAnimation.duration = 0.4
                        buttonAnimation.damping = 0.5
                        self.closeAreaView?.layer.cornerRadius = cornerRadius
                        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: {
                            self.frame = newFrame
                            self.closeAreaView?.bounds = CGRect(x: 0.0, y: 0, width: 45, height: 45)
                        }, completion: nil)
                    }
                    else {
                        self.frame = newFrame
                    }
                    self.intersectsWithCloseView = false
                }
                
            }
        }
        else if sender.state == .ended {
            if self.intersectsWithCloseView {
                self.delegate?.shouldDisableWidget(completion: { (shouldBeDisabled) in
                    if shouldBeDisabled {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.center = CGPoint(x: closeAreaView.center.x, y: superview.frame.height + closeAreaView.frame.height / 2)
                        }, completion: { (completed) in
                            HowtankWidget.shared.disable()
                        })
                    }
                    else {
                        self.resetPosition()
                    }
                    self.hideCloseArea()
                })
            }
            else {
                let velocity = sender.velocity(in: self.superview)
                self.resetPosition(withVelocity: velocity)
                self.hideCloseArea()
            }
        }
    }
        
    // MARK: - Close area
    
    @objc func showCloseAreaView() {
        guard let closeAreaView = self.closeAreaView, let superview = self.superview else {
            return
        }
        
        closeAreaView.center = CGPoint(x: closeAreaView.center.x, y: superview.frame.height + closeAreaView.frame.height / 2)
        closeAreaView.alpha = 1
        UIView.animate(withDuration: 0.3) {
            self.closeAreaBackgroundView?.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: {
            closeAreaView.center = CGPoint(x: closeAreaView.center.x, y: superview.frame.height - 70)
        }) { (completed) in
            self.closeAreaFullyDisplayed = true
        }
    }
    
    func hideCloseAreaView() {
        guard let closeAreaView = self.closeAreaView, let superview = self.superview else {
            return
        }
        
        self.closeAreaFullyDisplayed = false
        
        UIView.animate(withDuration: 0.3, animations: {
            closeAreaView.center = CGPoint(x: closeAreaView.center.x, y: superview.frame.height + closeAreaView.frame.height / 2)
            self.closeAreaBackgroundView?.alpha = 0
        }) { (completed) in
            closeAreaView.alpha = 0
        }
    }
    
    func hideCloseArea() {
        // Hide close area view
        if !chatStarted {
            self.closeAreaTimer?.invalidate()
            self.closeAreaTimer = nil
            self.hideCloseAreaView()
        }
    }
    
    func resetPosition(withVelocity velocity: CGPoint = CGPoint.zero) {
        guard let containerFrame = self.containerFrame else {
            return
        }
        
        let viewHalfWidth = self.frame.size.width / 2
        
        let velocityX = 0.1 * velocity.x
        let velocityY = 0.1 * velocity.y
        
        let finalX = self.frame.origin.x + velocityX + viewHalfWidth
        let finalY = self.frame.origin.y + velocityY + viewHalfWidth
        
        let minimumMargins = Theme.shared.minimumMargins()
        let finalXPosition = (finalX > containerFrame.width / 2) ? containerFrame.width - self.frame.width - minimumMargins.right + viewHalfWidth : minimumMargins.left + viewHalfWidth
        let finalYPosition = max(minimumMargins.top + viewHalfWidth + containerFrame.origin.y, min(containerFrame.height + containerFrame.origin.y - self.frame.height - minimumMargins.bottom + viewHalfWidth, finalY))
        
        if self.paneBehavior == nil {
            self.paneBehavior = PaneBehavior(item: self)
        }
        
        self.paneBehavior?.targetPoint = CGPoint(x: finalXPosition, y: finalYPosition)
        self.paneBehavior?.velocity = velocity
        self.initOrGetAnimator()?.addBehavior(self.paneBehavior!)
    }
    
}

