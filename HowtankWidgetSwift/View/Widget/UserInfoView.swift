//
//  UserInfoView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class UserInfoView: UIView {

    // MARK: - IBOutlets
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameAndLocationLabel: UILabel!
    @IBOutlet weak var expertTypeLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var chatCountAndThanksLabel: UILabel!
        
    // MARK: - Properties
    
    private var initialFrame = CGRect.zero
    private var whiteView: UIView?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        self.topView.backgroundColor = theme.color(.active)
        self.userNameAndLocationLabel.textColor = theme.color(.active)
        self.chatCountAndThanksLabel.textColor = theme.color(.active)
        self.backButton.tintColor = theme.color(.activeText)
        self.userNameLabel.textColor = theme.color(.activeText)
        
        self.userNameLabel.font = theme.fontOfSize(self.userNameLabel.font.pointSize)
        self.userNameAndLocationLabel.font = theme.fontOfSize(self.userNameAndLocationLabel.font.pointSize)
        self.expertTypeLabel.font = theme.boldFontOfSize(self.expertTypeLabel.font.pointSize)
        self.userBioLabel.font = theme.fontOfSize(self.userBioLabel.font.pointSize)
        self.chatCountAndThanksLabel.font = theme.fontOfSize(self.chatCountAndThanksLabel.font.pointSize)
        
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
        self.whiteView = UIView()
        self.whiteView!.backgroundColor = UIColor.white
        self.addSubview(self.whiteView!)
        self.sendSubviewToBack(self.whiteView!)
        
        self.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView(_:))))
    }
        
    // MARK: - Refresh methods
    
    func refresh(user: User, frame: CGRect, topViewHeight: CGFloat) {
        self.frame = frame
        self.topViewHeightConstraint.constant = topViewHeight
        
        self.userNameLabel.text = user.displayName
        if let city = user.city {
            self.userNameAndLocationLabel.text = "\(user.displayName) - \(city)"
        }
        else {
            self.userNameAndLocationLabel.text = "\(user.displayName)"
        }
        self.expertTypeLabel.text = user.expertType()
        self.userBioLabel.preferredMaxLayoutWidth = self.frame.width - 30
        if let bio = user.bio, bio.count > 0 {
            // Limit bio to 300 chars
            let userBio = bio.count > 300 ? bio.prefix(300) + "..." : bio
            self.userBioLabel.text = userBio
        }
        else {
            self.userBioLabel.text = ""
        }
        
        let chatCount = user.chatCount ?? 0
        var chatCountsAndThanks = chatCount > 0 ? "\(chatCount) \(chatCount > 1 ? "widget.label.conversations".loc() : "widget.label.conversation".loc())" : ""
        
        let thanksCount = user.thanks ?? 0
        if thanksCount > 0 {
            if chatCount > 0 {
                chatCountsAndThanks += ", "
            }
            chatCountsAndThanks += "\(thanksCount) \(thanksCount > 1 ? "widget.label.thanks".loc() : "widget.label.thank".loc())"
        }
        self.chatCountAndThanksLabel.text = chatCountsAndThanks
        
        user.image { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
        self.layoutIfNeeded()
    }
    
    func show(fromFrame frame: CGRect) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.initialFrame = frame
        
        self.topView.alpha = 0
        self.infoView.alpha = 0
        if let whiteView = self.whiteView {
            whiteView.frame = frame
            whiteView.layer.cornerRadius = whiteView.frame.width / 2
            whiteView.isHidden = false
        }
            
        let savedFrame = self.userImageView.frame
        self.userImageView.frame = frame
        self.isHidden = false
        
        self.animateCornerRadius(from: frame.width / 2, to: savedFrame.width / 2)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topView.alpha = 1
            self.infoView.alpha = 1
            self.userImageView.frame = savedFrame
        }, completion: { (completed) in
            self.whiteView?.isHidden = true
        })
    }
    
    private func animateCornerRadius(from fromValue: CGFloat, to toValue: CGFloat) {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fromValue = NSNumber(value: Float(fromValue))
        animation.toValue = NSNumber(value: Float(toValue))
        animation.duration = 0.3
        self.userImageView.layer.cornerRadius = toValue
        self.userImageView.layer.add(animation, forKey: "cornerRadius")
    }
        
    // MARK: - IBActions
    
    @IBAction func closeView(_ sender: Any) {
        self.whiteView?.isHidden = false
        
        self.animateCornerRadius(from: self.userImageView.frame.width / 2, to: self.initialFrame.width / 2)
        UIView.animate(withDuration: 0.3, animations: {
            self.topView.alpha = 0
            self.infoView.alpha = 0
            self.userImageView.frame = self.initialFrame
        }) { (completed) in
            self.isHidden = true
        }
    }

}
