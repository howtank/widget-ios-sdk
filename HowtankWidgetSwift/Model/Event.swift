//
//  Event.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

enum EventType : String {
    case openedChat = "opened_chat"
    case browsedPage = "browsed_page"
    case receivedAutomaticMessage = "received_automatic_message"
    case writingMessage = "writing_message"
    case wroteMessage = "wrote_message"
    case calledInterlocutor = "called_interlocutor"
    case canceledCall = "canceled_call"
    case joinedChat = "joined_chat"
    case bannedInterlocutor = "banned_interlocutor"
    case taggedChat = "tagged_chat"
    case transferredChat = "transferred_chat"
    case leftChat = "left_chat"
    case scoringInterlocutor = "scoring_interlocutor"
    case scoredInterlocutor = "scored_interlocutor"
    case thankedInterlocutor = "thanked_interlocutor"
    case notifiedAbuse = "notified_abuse"
    case closedChat = "closed_chat"
    case shareChat = "share_chat"
    case votedChat = "voted_chat"
    case unknown = "unknown"
}

class Event : NSObject {

    // MARK: - Properties
    
    let belongsToUser: Bool
    
    let id: String?
    private(set) var content: String?
    let localId: NSNumber?
    
    let publicationDate: Date
    let type: EventType
    
    var user: User?
    let tags: [String]
    
    // Browse page events
    let title: String?
    let url: String?
    
    // Host user
    let hostUserId: String?
    
    // Possible detected links
    private(set) var detectedLinks: [NSRegularExpression.Link]?
    private(set) var detectedImagesUrls: [URL]?
    let image: UIImage?

    var attributedContent: NSAttributedString?
    // MARK: - Initializer
    
    init(json: [String: Any], expertMode: Bool) {
        let chatCreator = json["chat_creator"] as! Bool
        self.belongsToUser = expertMode ? !chatCreator : chatCreator
        
        self.id = json["id"] as? String
        self.content = json["content"] as? String
        self.localId = json["local_id"] as? NSNumber
        
        // Date
        let publicationTimeStamp = json["publication_timestamp"] as! NSNumber
        let unixTimestamp = publicationTimeStamp.doubleValue / 1000
        self.publicationDate = Date(timeIntervalSince1970: unixTimestamp)
        
        if let typeString = json["type"] as? String, let type = EventType(rawValue: typeString) {
            self.type = type
        }
        else {
            self.type = .unknown
        }
        
        self.user = User(json: json)
        self.tags = (json["tags"] as? String)?.components(separatedBy: ",") ?? [String]()
        
        // Browse page properties
        self.title = json["title"] as? String
        self.url = json["url"] as? String
        
        // Host user
        self.hostUserId = json["host_user_id"] as? String
        
        self.image = nil
        
        super.init()
        
        if self.type == .wroteMessage {
            self.parseLinks()
            self.parseContent()
        }

    }

    func parseContent() {
        guard let content = content else {
            return
        }
        let fontSize: CGFloat = 15
        let attrContent = NSMutableAttributedString(string: content.withUnicodeEmojis(), attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        detectedLinks?.forEach({ (link) in
            var range = link.range
            // Avoid crash
            if (range.location + range.length > (content as NSString).length) {
                range.length = (content as NSString).length - range.location
            }
            attrContent.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        })
        // Bigger size if content is only emojis. Include weird character
        let emojiFontSize: CGFloat = 35
        if attrContent.string.containsOnlyEmojiOrSpaces, attrContent.string.emojis.filter({$0 == "️"}).count < 4 {
            self.attributedContent = NSAttributedString(string: attrContent.string.replacingOccurrences(of: " ", with: ""), attributes: [.font: UIFont.systemFont(ofSize: emojiFontSize)])
        } else {
            self.attributedContent = attrContent
        }
    }

    
    init(localId: Int, content: String) {
        self.type = .wroteMessage
        self.belongsToUser = true
        self.localId = NSNumber(value: localId)
        self.content = content
        self.publicationDate = Date()
        self.tags = [String]()
        
        // Other values are nil
        self.id = nil
        self.user = nil
        self.title = nil
        self.url = nil
        self.hostUserId = nil
        self.image = nil
        
        super.init()
        
        self.parseLinks()
        self.parseContent()
    }
    
    init(image: UIImage, user: User?) {
        self.type = .wroteMessage
        self.belongsToUser = true
        self.image = image
        self.user = user
        self.publicationDate = Date()
        self.tags = [String]()
        
        self.id = nil
        self.localId = nil
        self.title = nil
        self.url = nil
        self.hostUserId = nil
        
        super.init()
    }
    
    init(user: User, belongsToUser: Bool, type: EventType) {
        self.belongsToUser = belongsToUser
        self.user = user
        self.publicationDate = Date()
        self.tags = [String]()
        self.type = type
        
        self.id = nil
        self.localId = nil
        self.title = nil
        self.url = nil
        self.hostUserId = nil
        self.image = nil
        
        super.init()
    }
    
    init(type: EventType, belongsToUser: Bool) {
        self.type = type
        self.belongsToUser = belongsToUser
        self.publicationDate = Date()
        self.tags = [String]()
        
        self.id = nil
        self.localId = nil
        self.title = nil
        self.url = nil
        self.hostUserId = nil
        self.image = nil
        
        super.init()
    }
    
    class func events(json: [[String: Any]]?, expertMode: Bool) -> [Event]? {
        return json?.map({ Event(json: $0, expertMode: expertMode) })
    }
        
    // MARK: - Utility method
    
    private func parseLinks() {
        if let content = self.content {
            // Replace with emojis
            self.content = self.content?.withUnicodeEmojis()
            
            // Remove possible multiple spaces in string and trim
            self.content = NSRegularExpression.whiteSpaces.stringByReplacingMatches(in: content, options: [], range: NSMakeRange(0, (content as NSString).length), withTemplate: "$1").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Try to detect links or images in message
            let links = NSRegularExpression.links(in: self.content!)
            
            self.detectedLinks = links.filter({ !$0.image })
            self.detectedImagesUrls = links.filter({ $0.image }).map({ $0.url })
            
            // Remove images urls
            var totalOffset = 0
            links.filter({ $0.image }).forEach { (image) in
                self.content = (content as NSString).replacingCharacters(in: NSMakeRange(image.range.location - totalOffset, image.range.length), with: "")
                totalOffset += image.range.length
            }
        }
    }
    
}
