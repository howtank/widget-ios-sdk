//
//  RateCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 08/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol ScoreCellDelegate {
    func didScore(note: Int)
    func userSelected(user: User, imageView: UIImageView, fromFrame: CGRect)
}

class ScoreCell: UICollectionViewCell, UsersViewDelegate {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var completionIntroLabel: UILabel!
    @IBOutlet weak var usersView: UsersView!
    @IBOutlet weak var starsView: StarsRatingView!
    @IBOutlet weak var validationButton: UIButton!
        
    // MARK: - Properties
    
    var delegate: ScoreCellDelegate?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        
        self.validationButton.layer.cornerRadius = 5
        self.validationButton.backgroundColor = theme.color(.active)
        self.validationButton.setTitle("widget.button.validate".loc(), for: .normal)
        self.starsView.tintColor = theme.color(.active)
        
        self.completionIntroLabel.font = theme.boldFontOfSize(self.completionIntroLabel.font.pointSize)
        self.validationButton.titleLabel?.font = theme.fontOfSize(self.validationButton.titleLabel!.font.pointSize)
    }
        
    // MARK: - Refresh methods
    
    func refresh(cellWidth: CGFloat, thanks: Bool, interlocutors: [User]) {
        self.completionIntroLabel.preferredMaxLayoutWidth = cellWidth - 30
        self.completionIntroLabel.text = thanks ? "widget.rating.afterthanks".loc() : (interlocutors.count > 1 ? "widget.rating.intro.multiple".loc() : "widget.rating.intro.singular".loc())
        self.starsView.setValue(0)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.usersView.refresh(users: interlocutors, delegate: self)
    }
        
    // MARK: - IBActions
    
    @IBAction func validateRating(_ sender: Any) {
        if self.starsView.value > 0 {
            self.delegate?.didScore(note: Int(self.starsView.value))
        }
    }
        
    // MARK: - UsersViewDelegate methods
    
    func userSelected(_ user: User, imageView: UIImageView, fromFrame: CGRect) {
        self.delegate?.userSelected(user: user, imageView: imageView, fromFrame: fromFrame)
    }
    
}

