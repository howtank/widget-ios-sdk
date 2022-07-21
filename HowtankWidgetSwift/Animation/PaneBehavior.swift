//
//  PaneBehavior.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class PaneBehavior: UIDynamicBehavior {    
    // MARK: - Properties
    
    private let item: UIDynamicItem
    private var attachmentBehavior: UIAttachmentBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    
    var targetPoint: CGPoint? {
        didSet {
            self.attachmentBehavior?.anchorPoint = targetPoint ?? CGPoint.zero
        }
    }
    var velocity: CGPoint? {
        didSet {
            if let velocity = self.velocity, let currentVelocity = self.itemBehavior?.linearVelocity(for: self.item) {
                let velocityDelta = CGPoint(x: velocity.x - currentVelocity.x, y: velocity.y - currentVelocity.y)
                self.itemBehavior?.addLinearVelocity(velocityDelta, for: self.item)
            }
        }
    }
        
    // MARK: - Initializer

    init(item: UIDynamicItem) {
        self.item = item
        super.init()
        
        self.setup()
    }
    
    
    func setup() {
        let attachmentBehavior = UIAttachmentBehavior(item: self.item, attachedToAnchor: CGPoint.zero)
        attachmentBehavior.frequency = 3.5
        attachmentBehavior.damping = 0.4
        attachmentBehavior.length = 0
        self.addChildBehavior(attachmentBehavior)
        self.attachmentBehavior = attachmentBehavior
        
        let itemBehavior = UIDynamicItemBehavior(items: [self.item])
        itemBehavior.density = 10
        itemBehavior.resistance = 20
        self.addChildBehavior(itemBehavior)
        self.itemBehavior = itemBehavior
    }

}
