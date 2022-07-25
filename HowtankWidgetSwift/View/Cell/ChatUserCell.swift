//
//  ChatUserCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 06/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class ChatUserCell: UITableViewCell {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
        
    // MARK: - Properties
    
    private(set) var cellHeight: CGFloat = 0
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
        
    // MARK: - Refresh methods
    
    func refresh(event: Event, theme: Theme, communityMemberLabel: String?, supportAgentLabel: String?, forHeight: Bool) {
        if forHeight {
            self.cellHeight = self.separatorView.frame.origin.y + 10
        }
        else {
            self.userNameLabel.textColor = theme.color(.active)
            self.userNameLabel.font = theme.boldFontOfSize(self.userNameLabel.font.pointSize)
            self.userTypeLabel.font = theme.fontOfSize(self.userTypeLabel.font.pointSize)
            
            self.separatorView.backgroundColor = theme.color(.subtitle)
            self.userTypeLabel.textColor = theme.color(.subtitle)
            
            self.userNameLabel.text = event.user?.displayName
            self.userTypeLabel.text = event.user?.expertType(communityMemberLabel: communityMemberLabel, supportAgentLabel: supportAgentLabel)
            
            self.userImageView.alpha = 0
            event.user?.image(completionHandler: { (image) in
                DispatchQueue.main.async {
                    self.userImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.userImageView.alpha = 1
                    })
                }
            })
        }
    }
}

