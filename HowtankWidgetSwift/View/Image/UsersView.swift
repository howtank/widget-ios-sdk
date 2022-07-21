//
//  UsersView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 12/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol UsersViewDelegate {
    func userSelected(_ user: User, imageView: UIImageView, fromFrame: CGRect)
}

class UsersView: UIView {

    // MARK: - Properties
    
    var delegate: UsersViewDelegate?
    var users = [User]()
    
    static let userButtonWidth: CGFloat = 80
    static let userButtonOverlap: CGFloat = 10
        
    // MARK: - Refresh methods
    
    func refresh(users: [User], delegate: UsersViewDelegate) {
        self.users = users
        self.delegate = delegate
        
        // Remove all previous views
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let viewWidth = self.frame.width
        let totalUserButtonWidth = UsersView.userButtonWidth * CGFloat(self.users.count) - (UsersView.userButtonOverlap * CGFloat(users.count - 1))
        var beginOffset = (viewWidth - totalUserButtonWidth) / 2
        
        var userIndex = 0
        self.users.forEach { (user) in
            let button = UIButton(frame: CGRect(x: beginOffset, y: 0, width: UsersView.userButtonWidth, height: UsersView.userButtonWidth))
            button.layer.masksToBounds = true
            button.layer.cornerRadius = UsersView.userButtonWidth / 2
            user.image(completionHandler: { (userImage) in
                button.setImage(userImage, for: .normal)
            })
            button.tag = userIndex
            button.addTarget(self, action: #selector(buttonTouched(button:)), for: .touchUpInside)
            self.addSubview(button)
            beginOffset += UsersView.userButtonWidth - UsersView.userButtonOverlap
            userIndex += 1
        }
        
    }
    
    @objc func buttonTouched(button: UIButton) {
        if let frameInView = self.superview?.superview?.convert(button.frame, from: self), let imageView = button.imageView {
            self.delegate?.userSelected(users[button.tag], imageView: imageView, fromFrame: frameInView)
        }
    }

}

