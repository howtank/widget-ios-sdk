//
//  User.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 01/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

enum UserType : String {
    case community = "community"
    case support = "support"
}

public class User : NSObject {
    
    typealias ImageCompletionHandler = (_ image: UIImage) -> Void

    // PARK: - Properties
    
    public let id: String
    public let displayName: String
    
    let expertType: UserType?
    
    let levelBadgeId: String?
    let score: Float?
    let thanks: Int?
    let chatCount: Int?
    
    let bio: String?
    let city: String?
    
    let publicProfileUrl: String?
    let photoKey: String?
    
    private var imageCompletionHandlers = [ImageCompletionHandler]()
    private var image: UIImage?
        
    // MARK: - Initializer
    
    init?(json: [String: Any]) {
        guard let userId = json["user_id"] as? String else {
            return nil
        }
        
        self.id = userId
        self.displayName = json["user_display_name"] as? String ?? ""
        
        self.expertType = UserType(rawValue: json["user_expert_type"] as? String ?? "")
        
        self.levelBadgeId = json["user_level_badge"] as? String
        self.score = json["user_score"] as? Float
        self.thanks = json["user_thanks"] as? Int
        self.chatCount = json["user_chat_num"] as? Int
        
        self.bio = json["user_bio"] as? String
        self.city = json["user_city"] as? String
        
        self.publicProfileUrl = json["public_profile_url"] as? String
        self.photoKey = json["user_photo_key"] as? String
        
        super.init()
        
        // Load user image immediately in background
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.imageUrl()), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                    self.imageCompletionHandlers.forEach({ (completion) in
                        completion(image)
                    })
                }
            }
        }
    }    
    // MARK: - Utility methods
    
    public func imageUrl() -> String {
        if let photoKey = photoKey {
            return "\(Session.shared.secureCdnHost!)/user/image/\(self.id)/200/200?t=\(photoKey)"
        }
        return "\(Session.shared.secureCdnHost!)/user/image/\(self.id)/200/200"
    }
    
    func image(completionHandler: @escaping ImageCompletionHandler) {
        // If user image already exists, we just return it
        if let image = image {
            completionHandler(image)
        }
        else {
            // Add completion handler to the queue
            self.imageCompletionHandlers.append(completionHandler)
        }
    }
    
    func expertType(communityMemberLabel: String? = nil, supportAgentLabel: String? = nil) -> String {
        if let expertType = self.expertType {
            switch expertType {
            case .community:
                return communityMemberLabel ?? "widget.user.type.community".loc()
            case .support:
                return supportAgentLabel ?? "widget.user.type.support".loc()
            }
        }
        return ""
    }
    
}
