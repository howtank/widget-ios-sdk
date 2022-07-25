//
//  AbuseDisclaimerCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 08/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol AbuseDisclaimerCellDelegate {
    func cancelAbuse()
    func confirmAbuseDisclaimer()
}

class AbuseDisclaimerCell: UICollectionViewCell {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var abuseTitleLabel: UILabel!
    @IBOutlet weak var abuseBodyLabel: UILabel!
    @IBOutlet weak var abuseConfirmLabel: UILabel!
    
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
        
    // MARK: - Properties
    
    var delegate: AbuseDisclaimerCellDelegate?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        
        self.validationButton.layer.cornerRadius = 5
        self.validationButton.backgroundColor = theme.color(.active)
        
        self.abuseTitleLabel.font = theme.boldFontOfSize(self.abuseTitleLabel.font.pointSize)
        self.abuseBodyLabel.font = theme.fontOfSize(self.abuseBodyLabel.font.pointSize)
        self.abuseConfirmLabel.font = theme.boldFontOfSize(self.abuseConfirmLabel.font.pointSize)
        self.cancelButton.titleLabel?.font = theme.fontOfSize(self.cancelButton.titleLabel!.font.pointSize)
        self.validationButton.titleLabel?.font = theme.fontOfSize(self.validationButton.titleLabel!.font.pointSize)
        
        self.abuseTitleLabel.text = "widget.abuse.heading".loc()
        self.abuseBodyLabel.text = "widget.abuse.disclaimer".loc()
        self.abuseConfirmLabel.text = "widget.abuse.confirm".loc()
        self.validationButton.setTitle("widget.button.yes".loc(), for: .normal)
        self.cancelButton.setTitle("widget.button.cancel".loc(), for: .normal)
        self.cancelButton.setTitleColor(Theme.grayText, for: .normal)
    }
        
    // MARK: - Refresh methods
    
    func refresh(cellWidth: CGFloat) {
        let labelsWidth = cellWidth - 30
        self.abuseTitleLabel.preferredMaxLayoutWidth = labelsWidth
        self.abuseBodyLabel.preferredMaxLayoutWidth = labelsWidth
        self.abuseConfirmLabel.preferredMaxLayoutWidth = labelsWidth
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
        
    // MARK: - IBActions
    
    @IBAction func cancelAbuse(_ sender: Any) {
        self.delegate?.cancelAbuse()
    }
    
    @IBAction func confirmAbuse(_ sender: Any) {
        self.delegate?.confirmAbuseDisclaimer()
    }
    
}
 
