//
//  AbuseCompleteCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 08/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol AbuseCompleteCellDelegate {
    func abuseComplete()
}

class AbuseCompleteCell: UICollectionViewCell {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var validationButton: UIButton!
        
    // MARK: - Properties
    
    var delegate: AbuseCompleteCellDelegate?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        
        self.validationButton.layer.cornerRadius = 5
        self.validationButton.backgroundColor = theme.color(.active)
        
        self.messageLabel.text = "widget.abuse.success".loc()
        self.validationButton.setTitle("widget.abuse.close".loc(), for: .normal)
        
        self.messageLabel.font = theme.fontOfSize(self.messageLabel.font.pointSize)
        self.validationButton.titleLabel?.font = theme.fontOfSize(self.validationButton.titleLabel!.font.pointSize)
    }
    
    func refresh(cellWidth: CGFloat) {
        self.messageLabel.preferredMaxLayoutWidth = cellWidth - 30
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.delegate?.abuseComplete()
    }
    
}

