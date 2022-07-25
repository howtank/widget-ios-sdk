//
//  ChatEvent.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

enum ChatEventType {
    case calling
    case chatMessage(_: Event, local: Bool)
    case writing(_: Bool, distant: Bool)
    case userJoined(_: User)
    case userLeft(isSelf: Bool)
    case canceledCall
    case transferred(event: Event)
    case tagged(tags: [String])
    case closed
    
    // Expert mode
    case expertInitComplete
    case browsedPage(_: Event)
    case bannedInterlocutor(event: Event)
}


/*
 
 @protocol HowtankChatDelegate <NSObject>
 // Expert mode
 - (void)howtankChat:(nonnull HowtankChat *)chat expertInitComplete:(BOOL)complete;
 @end
 
 */
