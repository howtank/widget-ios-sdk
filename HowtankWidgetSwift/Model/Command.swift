//
//  Command.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 01/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

enum CommandType : String {
    case addEvent = "add_event"
    case getEvents = "get_events"
    case pickOpportunity = "pick_opportunity"
    case initMainWidget = "init_main_widget"
}

enum CommandKey : String {
    case apiVersion = "api_version"
    case channelAccessKey = "channel_access_key"
    case channelId = "channel_id"
    case chatId = "chat_id"
    case clientModel = "client_model"
    case command = "command"
    case eventContent = "event_content"
    case eventComment = "event_comment"
    case eventEmail = "event_email"
    case eventLocalId = "event_local_id"
    case eventReservedGroupId = "event_reserved_group_id"
    case eventReservedUserId = "event_reserved_user_id"
    case eventScore = "event_score"
    case eventTags = "event_tags"
    case eventTargetUserIds = "event_target_user_ids"
    case eventTitle = "event_title"
    case eventType = "event_type"
    case eventUrl = "event_url"
    case forceActive = "force_active"
    case hostId = "host_mnemonic"
    case hostSessionId = "host_session_id"
    case hostUrl = "host_url"
    case mark = "mark"
    case mode = "mode"
    case partnerAppVersion = "partner_app_version"
    case platform = "platform"
    case sessionId = "session_id"
    case timestamp = "timestamp"
    case userUid = "user_uid"
}

enum CommandMode : String {
    case endUser = "end_user"
    case expert = "expert"
    
    var backendServlet : String {
        switch self {
        case .endUser:
            return "wbackend"
        case .expert:
            return "backend"
        }
    }
}


class Command: NSObject {
    
    typealias CommandCompletionHandler = ((_ result: [String: Any]?, _ completion: () -> Void) -> Void)    
    // MARK: - Properties
    
    private(set) var parameters = [CommandKey: String]()
    var completionHandler: CommandCompletionHandler?
    
    // MARK: - Initializers
    
    init(type: CommandType) {
        super.init()
        self.addParam(key: .command, value: type.rawValue)
    }
    
    convenience init(eventType: EventType) {
        self.init(type: .addEvent)
        self.addParam(key: .eventType, value: eventType.rawValue)
    }    
    // MARK: - Utility methods
    
    func withParam(key: CommandKey, value: String?) -> Command {
        self.addParam(key: key, value: value)
        return self
    }
    
    func addParam(key: CommandKey, value: String?) {
        self.parameters[key] = value
    }
    
    func parametersString() -> String {
        return self.parameters.reduce("", { (result, element) -> String in
            "\(result)\(element.key.rawValue)=\(element.value.urlEncoded())&"
        })
    }
}

