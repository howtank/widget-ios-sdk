//
//  ChatMessageCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 06/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var bubbleViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var typingView: WritingView!
        
    // MARK: - Properties
    
    private var event: Event?
    
    private static let userMargin: CGFloat = 47
    private(set) var cellHeight: CGFloat = 0
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bubbleView.layer.cornerRadius = self.bubbleView.frame.height / 2
        
        // Gesture recognizers
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:))))
    }
    
    deinit {
        self.typingView.isHidden = true
        self.typingView.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.event = nil
    }
        
    // MARK: - Refresh methods
    
    func refreshWithTypingUser(_ typing: Bool, theme: Theme, distant: Bool) {
        self.bubbleView.backgroundColor = distant ? theme.color(.distantChat) : theme.color(.userChat)
        
        self.typingView.setBulletColor(color: distant ? theme.color(.distantWritingView) : theme.color(.userWritingView))
        self.typingView.isHidden = false
        self.chatLabel.isHidden = true
        self.chatLabel.text = "......"
        self.addMarginForUser(typing)
    }
    
    func refresh(event: Event, theme: Theme, forHeight: Bool, cellWidth: CGFloat) {
        self.event = event
        self.typingView.isHidden = true
        
        self.chatLabel.isHidden = false
        self.chatLabel.preferredMaxLayoutWidth = cellWidth - (event.user != nil ? 80 + ChatMessageCell.userMargin : 80)
        self.chatLabel.textColor = event.belongsToUser ? theme.color(.userChatText) : theme.color(.distantChatText)
        self.chatLabel.font = theme.fontOfSize(self.chatLabel.font.pointSize)
        self.bubbleView.backgroundColor = event.belongsToUser ? theme.color(.userChat) : theme.color(.distantChat)
        self.addMarginForUser(event.user != nil)
        self.chatLabel.attributedText = event.attributedContent
        if forHeight {
            self.setNeedsLayout()
            self.layoutIfNeeded()

            // TODO Use cell self height
            self.cellHeight = self.bubbleView.frame.origin.y + self.bubbleView.frame.size.height + 3
        }
    }
        
    // MARK: - Gestures
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "widget.mobile.app.text.cancel".loc(), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "widget.mobile.app.text.copy".loc(), style: .default, handler: { (action) in
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.chatLabel.text
            }))
            
            if event?.detectedLinks?.count ?? 0 > 0 {
                alertController.addAction(UIAlertAction(title: "widget.mobile.app.text.openlink".loc(), style: .default, handler: { (action) in
                    if let linkRange = self.event?.detectedLinks?.first?.range, let content = self.event?.content {
                        let link = (content as NSString).substring(with: linkRange)
                        if let url = URL(string: link) {
                            UIApplication.shared.open(url)
                        }
                    }
                }))
            }
            
            if let popPresenter = alertController.popoverPresentationController {
                popPresenter.sourceView = self.bubbleView
                popPresenter.sourceRect = self.bubbleView.bounds
            }
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.windowLevel = UIWindow.Level.normal
            window.makeKeyAndVisible()
            window.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
        
    // MARK: - Utility methods

    private func addMarginForUser(_ addMargin: Bool) {
        self.bubbleViewConstraint.constant = addMargin ? ChatMessageCell.userMargin : 10
    }

}

