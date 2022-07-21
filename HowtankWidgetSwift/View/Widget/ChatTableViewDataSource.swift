//
//  ChatTableViewDataSource.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol ChatTableViewDataSourceDelegate {
    func currentChat() -> Chat?
    func willZoomImage(imageView: UIImageView)
    func linkSelected(_ link: String)
    func userSelected(_ user: User, imageView: UIImageView, cellFrame: CGRect)
}

class ChatTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, ImageCellDelegate {    
    // MARK: - Properties
    
    var delegate: ChatTableViewDataSourceDelegate?
    var expertMode = false
    
    // When in expert mode, we might have specific labels for members
    var communityMemberLabel: String?
    var supportAgentLabel: String?
    
    var expertUsers = [User]()
    
    var chatEvents = [Event]()
    var lastLocalEvent: Event?
    var lastDistantEvent: Event?
    var writingUsers = [Bool]() // Distant = true, local = false
    
    var theme = Theme.shared
    var tableWidth: CGFloat = 0
        
    // MARK: - Lifecycle
    
    func reset() {
        self.chatEvents.removeAll()
        self.expertUsers.removeAll()
        self.writingUsers.removeAll()
        
        self.lastDistantEvent = nil
        self.lastLocalEvent = nil
    }
        
    // MARK: - UITableViewDataSource and delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.writingUsers.count
        }
        return self.chatEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Writing users
        if indexPath.section == 1 {
            let distantUser = self.writingUsers[indexPath.row]
            let cellIdentifier = distantUser ? "receivedMessageCell" : "sentMessageCell"
            let writingCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatMessageCell
            writingCell.refreshWithTypingUser(self.expertMode ? !distantUser : distantUser, theme: theme, distant: distantUser)
            return writingCell
        }
        
        if indexPath.row >= self.chatEvents.count {
            // Might happen when closing tab. We then return an empty cell
            return UITableViewCell()
        }
        
        let event = self.chatEvents[indexPath.row]
        switch event.type {
            
        case .transferredChat, .leftChat, .bannedInterlocutor:
            let specialEventCell = tableView.dequeueReusableCell(withIdentifier: "specialEventCell", for: indexPath) as! SpecialEventCell
            specialEventCell.refresh(event: event, cellWidth: self.tableWidth, theme: self.theme)
            return specialEventCell
            
        case .joinedChat:
            let cellIdentifier = event.belongsToUser ? "chatLocalUserCell" : "chatDistantUserCell"
            let userCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatUserCell
            userCell.refresh(event: event, theme: self.theme, communityMemberLabel: self.communityMemberLabel, supportAgentLabel: self.supportAgentLabel, forHeight: false)
            return userCell
            
        case .browsedPage:
            let browsedUrlCell = tableView.dequeueReusableCell(withIdentifier: "browsedUrlCell", for: indexPath) as! BrowsedUrlCell
            browsedUrlCell.refresh(event: event, theme: self.theme)
            return browsedUrlCell
            
        case .shareChat:
            let shareChatCell = tableView.dequeueReusableCell(withIdentifier: "shareChatCell", for: indexPath) as! ShareChatCellProtocol & UITableViewCell
            shareChatCell.refresh(chat: self.delegate?.currentChat())
            return shareChatCell
            
        case .wroteMessage:
            if event.image != nil {
                let cellIdentifier = event.belongsToUser ? "sentImageCell" : "receivedImageCell"
                let imageCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ImageCell
                imageCell.delegate = self
                imageCell.refresh(event: event)
                return imageCell
            }
            
        default:
            break
        }
        
        // Other cases
        let cellIdentifier = event.belongsToUser ? "sentMessageCell" : "receivedMessageCell"
        let messageCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatMessageCell
        messageCell.refresh(event: event, theme: self.theme, forHeight: false, cellWidth: self.tableWidth)
        return messageCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Writing users
        if indexPath.section == 1 {
            return 38
        }
        
        if indexPath.row >= self.chatEvents.count {
            // Might happen when closing tab. We then return 0
            return 0
        }
        
        let event = self.chatEvents[indexPath.row]
        switch event.type {
            
        case .transferredChat, .leftChat, .bannedInterlocutor:
            let specialEventCell = tableView.dequeueReusableCell(withIdentifier: "specialEventCell") as! SpecialEventCell
            specialEventCell.refresh(event: event, cellWidth: self.tableWidth, theme: self.theme)
            return specialEventCell.cellHeight
            
        case .joinedChat:
            let cellIdentifier = event.belongsToUser ? "chatLocalUserCell" : "chatDistantUserCell"
            let userCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChatUserCell
            userCell.refresh(event: event, theme: self.theme, communityMemberLabel: self.communityMemberLabel, supportAgentLabel: self.supportAgentLabel, forHeight: true)
            return userCell.cellHeight
            
        case .browsedPage:
            return 40
            
        case .shareChat:
            return 100
            
        case .wroteMessage:
            if event.image != nil {
                let cellIdentifier = event.belongsToUser ? "sentImageCell" : "receivedImageCell"
                let imageCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ImageCell
                return imageCell.cellHeight(event: event)
            }
            
        default:
            break
        }
        
        // Other cases
        let cellIdentifier = event.belongsToUser ? "sentMessageCell" : "receivedMessageCell"
        let messageCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChatMessageCell
        messageCell.refresh(event: event, theme: self.theme, forHeight: true, cellWidth: self.tableWidth)
        return messageCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let event = self.chatEvents[indexPath.row]
        if let links = event.detectedLinks, links.count > 0 {
            // If a link is detected, we call the widget delegate so it can be handled by partner application
            // For now, we consider that there is only one link - so the first link will be send
            let linkValue = (event.content! as NSString).substring(with: links.first!.range)
            self.delegate?.linkSelected(linkValue)
        }
        else if event.type == .browsedPage, let url = event.url {
            self.delegate?.linkSelected(url)
        }
        else if event.type == .joinedChat, let userCell = tableView.cellForRow(at: indexPath) as? ChatUserCell, let user = event.user {
            let userImageFrame = userCell.userImageView.frame
            let cellFrame = CGRect(x: userImageFrame.origin.x, y: userImageFrame.origin.y + userCell.frame.origin.y, width: userImageFrame.width, height: userImageFrame.height)
            self.delegate?.userSelected(user, imageView: userCell.userImageView, cellFrame: cellFrame)
        }
    }
        
    // MARK: - ImageCellDelegate methods
    
    func willZoomImage(imageView: UIImageView) {
        self.delegate?.willZoomImage(imageView: imageView)
    }
    
}
 
