//
//  ExpertChat.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import Foundation

public class ExpertChat {

    // MARK: - Properties
    
    let chatId: String
    public let hostId: String
    let name: String
    public let platform: String
    public let confidential: Bool
    
    public let spectator: Bool
    let closed: Bool
    
    public var theme: Theme
    
    let shareable: Bool
    let votes: Int
    
    // When in expert mode, we might have specific labels for members
    public var communityMemberLabel: String?
    public var supportAgentLabel: String?
        
    // MARK: - Initializer
    
    public init(chatId: String, hostId: String, name: String, platform: String, confidential: Bool, spectator: Bool, closed: Bool, theme: Theme, shareable: Bool, votes: Int) {
        self.chatId = chatId
        self.hostId = hostId
        self.name = name
        self.platform = platform
        self.confidential = confidential
        
        self.spectator = spectator
        self.closed = closed
        
        self.theme = theme
        
        self.shareable = shareable
        self.votes = votes
    }

}
