//
//  SpecialEventCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 06/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class SpecialEventCell: UITableViewCell {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var eventLabel: UILabel!
        
    // MARK: - Properties
    
    private(set) var cellHeight: CGFloat = 0
    
    // MARK: - Refresh methods
    
    func refresh(event: Event, cellWidth: CGFloat, theme: Theme) {
        self.bounds = CGRect(x: 0, y: 0, width: cellWidth, height: self.bounds.size.height)
        
        switch event.type {
        case .transferredChat:
            self.eventLabel.text = "widget.event.transferred_chat".loc()
        case .bannedInterlocutor:
            self.eventLabel.text = "widget.messages.expert.event.banned_interlocutor".loc()
        case .leftChat:
            if let user = event.user {
                self.eventLabel.text = "widget.event.memberleft".loc().replacingOccurrences(of: "{{>user_display_name}}", with: user.displayName)
            }
            else {
                self.eventLabel.text = "widget.messages.expert.event.closed_chat".loc()
            }
        default:
            break
        }
        
        self.eventLabel.preferredMaxLayoutWidth = cellWidth - 30
        self.eventLabel.textColor = theme.color(.subtitle)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.cellHeight = self.eventLabel.frame.origin.y + self.eventLabel.frame.height + 10
    }

}
