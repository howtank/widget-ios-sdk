//
//  EventType.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 30/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

@objc public enum WidgetEventType: Int {
    
    case initialized
    case opened
    case disabled
    case displayed
    case hidden
    case unavailable//(reason: String)
    case linkSelected//(link: String)
    case closed//(chatClosed: Bool)
    case scoringInterlocutor
    case thankingInterlocutor
    case scoredInterlocutor//(note: Int)
    case thankedInterlocutor
    case calledInterlocutor
    
}

public enum ExpandedWidgetEventType {
    
    case closed(chatView: ExpandedWidgetView, chatClosed: Bool)
    case newChatMessage(chatView: ExpandedWidgetView, message: String)
    case userWriting(writing: Bool, distant: Bool)
    case linkSelected(link: String)
    case chatInitialized
    case scoringInterlocutor
    case thankingInterlocutor
    case scoredInterlocutor(note: Int)
    case thankedInterlocutor
    case shouldRedrawWidget
    
}
