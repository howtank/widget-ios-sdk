//
//  ThanksCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 08/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol ThanksCellDelegate {
    func didThanks()
    func didNotThanks()
    func shouldReportAbuse()
    func userSelected(user: User, imageView: UIImageView, fromFrame: CGRect)
}

class ThanksCell: UICollectionViewCell, UsersViewDelegate {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var completionIntroLabel: UILabel!
    @IBOutlet weak var closeLink: UILabel!
    @IBOutlet weak var usersView: UsersView!
    @IBOutlet weak var validationButton: UIButton!
        
    // MARK: - Properties
    
    var delegate: ThanksCellDelegate?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        
        self.validationButton.layer.cornerRadius = 5
        self.validationButton.backgroundColor = theme.color(.active)
        
        self.validationButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.validationButton.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.validationButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        self.completionIntroLabel.font = theme.boldFontOfSize(self.completionIntroLabel.font.pointSize)
        self.validationButton.titleLabel?.font = theme.fontOfSize(self.validationButton.titleLabel!.font.pointSize)
        
        let attributedString = NSMutableAttributedString(string: "widget.thanks.close".loc())
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedString.length))
        self.closeLink.attributedText = attributedString
        // TODO remove the line below if the feature "close" is enabled
        self.closeLink.isHidden = true
        
        self.validationButton.setTitle("widget.button.thanks".loc(), for: .normal)
    }
        
    // MARK: - Refresh methods
    
    func refresh(cellWidth: CGFloat, interlocutors: [User]) {
        self.completionIntroLabel.preferredMaxLayoutWidth = cellWidth - 30
        self.completionIntroLabel.text = interlocutors.count > 1 ? "widget.thanks.intro.multiple".loc() : "widget.thanks.intro.singular".loc()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.usersView.refresh(users: interlocutors, delegate: self)
    }
        
    // MARK: - IBActions
    
    @IBAction func validateRating(_ sender: Any) {
        self.delegate?.didThanks()
    }
    
    @IBAction func close(_ sender: Any) {
        self.delegate?.didNotThanks()
    }
    
    @IBAction func shouldReportAbuse(_ sender: Any) {
        self.delegate?.shouldReportAbuse()
    }
        
    // MARK: - UsersViewDelegate methods
    
    func userSelected(_ user: User, imageView: UIImageView, fromFrame: CGRect) {
        self.delegate?.userSelected(user: user, imageView: imageView, fromFrame: fromFrame)
    }
    
}

