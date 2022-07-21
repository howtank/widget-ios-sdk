//
//  Chat.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public enum ChatStatus {
    case opened
    case calling
    case joined
    case completed
    case closed
}

protocol ChatDelegate {
    func chatEvent(type: ChatEventType)
}

extension Chat {
    func chatDebug(_ message: String) {
        if HowtankWidget.shared.verboseMode {
            cDebug("[Chat \(self.chatId ?? "null")] \(message)")
        }
    }
}

public class Chat {    
    // MARK: - Typealias
    
    typealias AbuseCompletionHandler = (_ succes: Bool, _ errorType: AbuseErrorType) -> Void
        
    // MARK: - Properties
    
    public let hostId: String
    
    var delegate: ChatDelegate?
        
    private var pageName: String?
    private var pageUrl: String?
    
    private var hostSessionId: String?
    private let commandMode: CommandMode
    private var platform: String?
    
    public private(set) var chatId: String?
    private var channelId: String?
    private var channelAccessKey: String?
    private var sessionId: String?
    
    public private(set) var status = ChatStatus.opened // Default status is Opened
    private var closed = false // Set to true when chat is closed so we don't listen to events anymore
    private var writingMessageLock = false
    
    private var localIdCount = 1000
    private var writingMessageDistantId: String?
    private var writingMessageLocalId: String?
    
    private var chatSession: URLSession?
    
    // Users
    private(set) var communityInterlocutors = [User]()
    private(set) var supportInterlocutors = [User]()
    public private(set) var votingUsers = [String]()
    
    // Queue
    private var commandsQueue = [Command]()
    private let commandsDispatchQueue = DispatchQueue(label: "chatCommandsQueue")
    private var eventsQueueRunning = false
    private var eventsDataTask: URLSessionDataTask?
    private var lastTimestamp: NSNumber?
    
    // Expert
    private var expertInitialization = false
    public internal(set) var spectator = false
    private(set) var shareable = false
    public private(set) var votes = 0
    public private(set) var currentTags = [String]()
        
    // MARK: - Initialization method
    
    init(hostId: String, pageName: String, pageUrl: String?, completionHandler: @escaping (_ active: Bool, _ error: String?) -> Void) {
        // Init properties
        self.commandMode = .endUser
        self.hostId = hostId
        self.pageName = pageName
        self.pageUrl = pageUrl
        
        self.hostSessionId = UserDefaults.standard.string(forKey: Constants.Keys.hostSessionId)
        
        self.commonInit()
        
        let command = Command(type: .initMainWidget)
            .withParam(key: .apiVersion, value: String(Constants.Api.version))
            .withParam(key: .partnerAppVersion, value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
            .withParam(key: .clientModel, value: UIDevice.current.model)
            .withParam(key: .hostId, value: self.hostId)
        
        // Get or compute Unique User ID
        var uuid = UserDefaults.standard.string(forKey: Constants.Keys.uuid)
        if uuid == nil {
            uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: Constants.Keys.uuid)
            UserDefaults.standard.synchronize()
        }
        command.addParam(key: .userUid, value: uuid)
        
        // Completion handler
        command.completionHandler = { (result, completed) in
            if let result = result {
                if result["accepted"] as? Bool == true, result["active"] as? Bool == true, let resources = result["resources"] as? [String: Any] {
                    if let messages = resources["messages"] as? [String: String] {
                        Messages.shared.fill(messages: messages)
                    }
                    if let theme = resources["theme"] as? [String: String] {
                        Theme.shared.fill(theme: theme)
                    }
                    self.platform = resources["platform"] as? String
                    
                    if self.hostSessionId == nil {
                        cDebug("Host session id not set, initializing")
                        self.hostSessionId = result["host_session_id"] as? String
                        UserDefaults.standard.set(self.hostSessionId, forKey: Constants.Keys.hostSessionId)
                        UserDefaults.standard.synchronize()
                    }
                    completionHandler(true, nil)
                }
                else {
                    if let error = result["error"] as? String {
                        completionHandler(false, error)
                    }
                    else {
                        completionHandler(false, "Widget is inactive for this host mnemonic")
                    }
                }
            }
            else {
                completionHandler(false, "Unable to get init command result")
            }
            
            completed()
        }
        
        self.addCommandToQueue(command: command)
    }
    
    init(delegate: ChatDelegate, expertChat: ExpertChat, authorization: String?) {
        self.commandMode = .expert
        
        self.chatId = expertChat.chatId
        self.hostId = expertChat.hostId
        self.spectator = expertChat.spectator
        
        // Share chats
        self.shareable = expertChat.shareable
        self.votes = expertChat.votes
        
        self.expertInitialization = true
        
        self.configure(delegate: delegate, authorization: authorization)
        
        self.eventsListener()
    }
    
    
    func configure(delegate: ChatDelegate?, authorization: String? = nil) {
        self.delegate = delegate
        self.commonInit(authorization: authorization)
    }
    
    private func commonInit(authorization: String? = nil) {
        // Init objects
        self.communityInterlocutors.removeAll()
        self.supportInterlocutors.removeAll()
        self.votingUsers.removeAll()
        self.commandsQueue.removeAll()
        self.status = .opened
        self.writingMessageLock = false
        self.closed = false
        self.localIdCount = 1000
        
        self.channelId = nil
        self.channelAccessKey = nil
        self.sessionId = nil
        
        if self.commandMode != .expert {
            self.chatId = nil
        }
        
        // Initialize session
        self.chatSession = Chat.widgetUrlSession(authorization: authorization)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private static func widgetUrlSession(authorization: String? = nil) -> URLSession {
        // Initialize session
        let config = URLSessionConfiguration.default
        var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        if appName == nil || appName!.count == 0 {
            appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        }
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let userAgent = "iPhone Widget (\(Constants.widgetVersion)) - \(appName ?? "Unknown") (\(appVersion ?? "Unknown"))"
        var headers = ["User-Agent": userAgent]
        if let authorization = authorization {
            headers["Authorization"] = authorization
        }
        config.httpAdditionalHeaders = headers
        
        return URLSession(configuration: config)
    }
    
    @objc func applicationWillTerminate(_ notification: Notification)
    {
        cDebug("Application will close. Trying to send close event.")
        self.closeChat()
    }
    
    deinit {
        self.chatSession?.delegateQueue.isSuspended = true
        self.chatSession?.invalidateAndCancel()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
        
    // MARK: - Queue management
    
    private func addCommandToQueue(command: Command) {
        self.commandsDispatchQueue.async {
            self.commandsQueue.append(command)
            self.commandsQueueRunner()
        }
    }
    
    private func commandsQueueRunner() {
        guard !self.eventsQueueRunning, commandsQueue.count > 0 else {
            return
        }
        self.eventsQueueRunning = true
        
        commandsDispatchQueue.async {
            if self.commandsQueue.count > 0 {
                let command = self.commandsQueue.remove(at: 0)
                DispatchQueue.main.async {
                    // TODO: handle error - set a number of retries
                    _ = self.apiCall(command: command, completion: { (result) in
                        if let completion = command.completionHandler {
                            completion(result, {
                                self.callNextEventInQueue()
                            })
                        }
                        else {
                            self.callNextEventInQueue()
                        }
                    })
                }
            }
        }
    }
    
    private func callNextEventInQueue() {
        self.eventsQueueRunning = false
        self.commandsQueueRunner()
    }
    
    private func apiCall(command: Command, completion: @escaping (_ result: [String: Any]?) -> Void) -> URLSessionDataTask? {
        guard let apiHost = Session.shared.secureApiHost else {
            cDebug("Api host not set. Aborting")
            completion(nil)
            return nil
        }
        
        // Add global parameters to call
        if command.parameters[.eventLocalId] == nil {
            command.addParam(key: .eventLocalId, value: "0")
        }
        
        _ = command.withParam(key: .mode, value: self.commandMode.rawValue)
                .withParam(key: .hostSessionId, value: self.hostSessionId)
                .withParam(key: .sessionId, value: self.sessionId)
                .withParam(key: .chatId, value: self.chatId)
                .withParam(key: .channelAccessKey, value: self.channelAccessKey)
                .withParam(key: .channelId, value: self.channelId)
                .withParam(key: .hostUrl, value: self.pageUrl)
        
        let requestUrl = "\(apiHost)/\(self.commandMode.backendServlet)?\(command.parametersString())"
        if let event = command.parameters[.eventType] {
            chatDebug("New event: \(event)")
        }
        chatDebug("Request URL: \(requestUrl)")
        
        if let url = URL(string: requestUrl) {
            let dataTask = self.chatSession?.dataTask(with: url, completionHandler: { (data, response, error) in
                if let data = data, let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonResult as? [String: Any] {
                    if let accepted = json["accepted"] as? Bool, accepted {
                        completion(json)
                    }
                    else {
                        self.chatDebug("Event not accepted: \(json)")
                        completion(json)
                    }
                }
                else {
                    if !self.closed {
                        // Wait 1s before trying a new call
                        self.chatDebug("Error adding command \(command.parameters[.command] ?? ""), retrying")
                        Utility.delay(Constants.Delay.errorCallback, closure: {
                            _ = self.apiCall(command: command, completion: completion)
                        })
                    }
                }
            })
            
            dataTask?.resume()
            return dataTask
        }
        else {
            cDebug("URL is malformed: \n" + requestUrl)
        }
        return nil
    }
        
    // MARK: - Public chat methods
 
    func writingMessage() {
        if self.status == .joined {
            self.writingMessageEvent()
        }
    }
    
    public func wroteMessage(_ message: String, completion: (() -> Void)? = nil) {
        if self.canWriteMessage() {
            if status == .opened {
                // This status requires that we join a new chat session
                self.delegate?.chatEvent(type: .calling)
                self.browsePageEvent(pageName: self.pageName, pageUrl: self.pageUrl)
                self.wroteMessageEvent(message: message, completion: completion)
                self.calledInterlocutorEvent()
            }
            else {
                // Just push the new message to the list
                self.wroteMessageEvent(message: message, completion: completion)
            }
        }
    }
    
    public func closeChat() {
        if !self.spectator, ![ChatStatus.opened, ChatStatus.closed].contains(self.status) {
            if self.commandMode == .expert {
                self.leftChatEvent()
            }
            else {
                self.closeChatEvent()
            }
        }
        else {
            self.closed = true
            self.eventsDataTask?.cancel()
            self.eventsDataTask = nil
        }
    }
    
    func browsePage(name: String, url: String?) {
        let shouldBrowsePage = self.pageUrl != url
        self.pageName = name
        self.pageUrl = url
        if shouldBrowsePage, [ChatStatus.calling, ChatStatus.joined].contains(self.status) {
            self.browsePageEvent(pageName: self.pageName, pageUrl: self.pageUrl)
        }
    }
    
    /// Called before scoring chat
    func willScoreInterlocutor() {
        if ![ChatStatus.opened, ChatStatus.closed].contains(self.status) {
            self.scoringInterlocutorEvent()
        }
    }
    
    /// User scored chat
    func scoredInterlocutors(interlocutorIds: String, note: Int) {
        if ![ChatStatus.opened, ChatStatus.closed].contains(self.status) {
            self.scoredInterlocutorEvent(interlocutorIds: interlocutorIds, note: note)
        }
    }
    
    /// User said thanks!
    func thankedInterlocutors(interlocutorIds: String) {
        if ![ChatStatus.opened, ChatStatus.closed].contains(self.status) {
            self.thanksInterlocutorEvent(interlocutorIds: interlocutorIds)
        }
    }
    
    /// Notify abuse
    func notifyAbuse(email: String, comment: String, completion: @escaping AbuseCompletionHandler) {
        if status != .opened {
            self.shareable = false
            let interlocutorIds = (self.communityInterlocutors + self.supportInterlocutors).map({ $0.id }).joined(separator: ",")
            
            self.notifiedAbuseEvent(interlocutorIds: interlocutorIds, email: email, comment: comment, completion: completion)
        }
    }
        
    // MARK: - Expert chat methods
    
    public func addTag(_ tag: String) {
        self.currentTags.append(tag)
        self.taggedChatEvent(tags: self.currentTags.joined(separator: ","))
    }
    
    public func removeTag(_ tag: String) {
        self.currentTags = self.currentTags.filter({ $0 != tag })
        self.taggedChatEvent(tags: self.currentTags.joined(separator: ","))
    }
    
    public func transferChat(tags: String?, reservedUserId: String?, reservedGroupId: String?) {
        self.transferredChatEvent(tags: tags, reservedUserId: reservedUserId, reservedGroupId: reservedGroupId)
    }
    
    public func banInterlocutor() {
        self.shareable = false // Chat won't be shareable if user has been banned
        self.banInterlocutorEvent()
    }
    
    public func vote() {
        self.voteEvent()
        self.votes += 1
    }
        
    // MARK: - Utility methods
    
    private func canWriteMessage() -> Bool {
        return ![ChatStatus.completed, ChatStatus.closed].contains(self.status)
    }
        
    // MARK: - Events calls
    
    private func eventsListener() {
        let command = Command(type: .getEvents)
        command.addParam(key: .timestamp, value: lastTimestamp?.stringValue)
        if self.closed {
            chatDebug("Stop listening to events. Chat is closed")
            return
        }
        chatDebug("Listening to events")
        
        self.eventsDataTask = self.apiCall(command: command, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            if let result = result, let events = result["events"] as? [[String: Any]] {
                cDebug("EVENTS: \(events)")
                
                // For expert mode, we update the session id, channel key
                if strongSelf.commandMode == .expert, let channelId = result["channel_id"] as? String {
                    strongSelf.channelId = channelId
                    strongSelf.channelAccessKey = result["channel_access_key"] as? String
                    strongSelf.sessionId = result["session_id"] as? String
                }
                
                let events = Event.events(json: events, expertMode: strongSelf.commandMode == .expert)
                events?.forEach({ (event) in
                    strongSelf.localIdCount += 1
                    
                    switch event.type {
                    case .wroteMessage:
                        if event.belongsToUser {
                            strongSelf.writingMessageLocalId = nil
                        }
                        else {
                            strongSelf.writingMessageDistantId = nil
                        }
                        strongSelf.delegate?.chatEvent(type: .chatMessage(event, local: false))
                        
                    case .writingMessage:
                        if strongSelf.spectator || !event.belongsToUser {
                            if event.belongsToUser {
                                strongSelf.writingMessageLocalId = event.id
                            }
                            else {
                                strongSelf.writingMessageDistantId = event.id
                            }
                            strongSelf.delegate?.chatEvent(type: .writing(true, distant: !event.belongsToUser))
                            Utility.delay(Constants.Delay.distantWritingMessageLock, closure: {
                                // Ensure user is not still writing before sending the event
                                let writingMessageId = event.belongsToUser ? strongSelf.writingMessageLocalId : strongSelf.writingMessageDistantId
                                if writingMessageId == event.id {
                                    strongSelf.delegate?.chatEvent(type: .writing(false, distant: !event.belongsToUser))
                                }
                            })
                        }
                        
                    case .joinedChat:
                        strongSelf.status = .joined
                        if let user = event.user, let expertType = user.expertType {
                            switch expertType {
                            case .community:
                                strongSelf.communityInterlocutors.append(user)
                            case .support:
                                strongSelf.shareable = false // Chat won't be shareable if a support interlocutor has joined it
                                strongSelf.supportInterlocutors.append(user)
                            }
                            strongSelf.delegate?.chatEvent(type: .userJoined(user))
                        }
                        
                    case .browsedPage:
                        if strongSelf.commandMode == .expert {
                            strongSelf.delegate?.chatEvent(type: .browsedPage(event))
                        }
                        
                    case .scoringInterlocutor:
                        // Only for experts
                        strongSelf.status = .completed
                        if strongSelf.spectator || !event.belongsToUser {
                            strongSelf.delegate?.chatEvent(type: .userLeft(isSelf: event.belongsToUser))
                        }
                        
                    case .leftChat:
                        strongSelf.status = .completed
                        strongSelf.delegate?.chatEvent(type: .userLeft(isSelf: event.belongsToUser))
                        
                    case .canceledCall:
                        strongSelf.status = .closed
                        strongSelf.delegate?.chatEvent(type: .canceledCall)
                        
                    case .bannedInterlocutor:
                        if strongSelf.commandMode == .expert {
                            strongSelf.status = .closed
                            strongSelf.delegate?.chatEvent(type: .bannedInterlocutor(event: event))
                        }
                        
                    case .transferredChat:
                        strongSelf.delegate?.chatEvent(type: .transferred(event: event))
                        if event.tags.count > 0, strongSelf.commandMode == .expert {
                            strongSelf.currentTags = event.tags
                            strongSelf.delegate?.chatEvent(type: .tagged(tags: event.tags))
                        }
                        
                    case .closedChat:
                        strongSelf.status = .closed
                        strongSelf.delegate?.chatEvent(type: .closed)
                        strongSelf.closed = true
                        strongSelf.chatDebug("Chat closed")
                        
                    case .taggedChat:
                        if strongSelf.commandMode == .expert {
                            strongSelf.currentTags = event.tags
                            strongSelf.delegate?.chatEvent(type: .tagged(tags: event.tags))
                        }
                        
                    case .votedChat:
                        if strongSelf.commandMode == .expert, let user = event.user {
                            strongSelf.votingUsers.append(user.id)
                        }
                        
                    case .openedChat, .calledInterlocutor, .scoredInterlocutor, .thankedInterlocutor, .notifiedAbuse:
                        // Nothing to do, status has been already changed
                        break
                        
                    default:
                        cDebug("\n*********** EVENT NOT HANDLED ***********\n\(event)")
                    }
                })
                
                if strongSelf.expertInitialization {
                    strongSelf.expertInitialization = false
                    strongSelf.delegate?.chatEvent(type: .expertInitComplete)
                }
                
                // Save last mark
                strongSelf.lastTimestamp = result["timestamp"] as? NSNumber
                if strongSelf.status != .closed { // Once the chat is closed, there will be no more events
                    Utility.delay(Constants.Delay.nextCall, closure: {
                        strongSelf.eventsListener()
                    })
                }
            }
            else {
                // Wait 1s before trying a new call
                Utility.delay(Constants.Delay.errorCallback, closure: {
                    strongSelf.eventsListener()
                })
            }
            
        })
    }
    
    
    private func browsePageEvent(pageName: String?, pageUrl: String?) {
        let command = Command(eventType: .browsedPage)
        command.addParam(key: .eventUrl, value: pageUrl ?? "/")
        command.addParam(key: .eventTitle, value: pageName ?? "")
        command.addParam(key: .hostId, value: self.hostId)
        command.addParam(key: .platform, value: self.platform)
        
        if status == .opened {
            command.completionHandler = { (result, completed) in
                if let result = result {
                    self.channelId = result["channel_id"] as? String
                    self.chatId = result["chat_id"] as? String
                    self.channelAccessKey = result["channel_access_key"] as? String
                    self.sessionId = result["session_id"] as? String
                    
                    cDebug("Chat initialized")
                    self.eventsListener()
                    
                    completed()
                }
            }
        }
        self.addCommandToQueue(command: command)
    }
    
    private func calledInterlocutorEvent() {
        self.status = .calling
        
        let command = Command(eventType: .calledInterlocutor)
        self.addCommandToQueue(command: command)
    }
    
    private func wroteMessageEvent(message: String, completion: (() -> Void)?) {
        self.localIdCount += 1
        let localId = localIdCount
        
        let command = Command(eventType: .wroteMessage)
        command.addParam(key: .eventContent, value: message.withTextEmojis())
        command.addParam(key: .eventLocalId, value: String(localId))
        if let completion = completion {
            command.completionHandler = { (result, completed) in
                completed()
                completion()
            }
        }
        
        self.addCommandToQueue(command: command)
        
        // Display message
        let event = Event(localId: localId, content: message)
        self.delegate?.chatEvent(type: .chatMessage(event, local: true))
    }
    
    private func writingMessageEvent() {
        if self.writingMessageLock {
            return
        }
        self.writingMessageLock = true
        
        let command = Command(eventType: .writingMessage)
        command.completionHandler = { (result, completed) in
            if result != nil {
                completed()
            }
        }
        
        Utility.delay(Constants.Delay.writingMessageLock) {
            self.writingMessageLock = false
        }
        self.addCommandToQueue(command: command)
    }
    
    private func closeChatEvent() {
        self.addCommandToQueue(command: Command(eventType: .closedChat))
    }
    
    private func leftChatEvent() {
        self.addCommandToQueue(command: Command(eventType: .leftChat))
    }
    
    private func scoringInterlocutorEvent() {
        self.status = .completed
        self.addCommandToQueue(command: Command(eventType: .scoringInterlocutor))
    }
    
    private func scoredInterlocutorEvent(interlocutorIds: String, note: Int) {
        let command = Command(eventType: .scoredInterlocutor)
        command.addParam(key: .eventScore, value: String(note))
        command.addParam(key: .eventTargetUserIds, value: interlocutorIds)
        self.addCommandToQueue(command: command)
    }
    
    private func thanksInterlocutorEvent(interlocutorIds: String) {
        let command = Command(eventType: .thankedInterlocutor)
        command.addParam(key: .eventTargetUserIds, value: interlocutorIds)
        self.addCommandToQueue(command: command)
    }
    
    private func taggedChatEvent(tags: String) {
        let command = Command(eventType: .taggedChat)
        command.addParam(key: .eventTags, value: tags)
        self.addCommandToQueue(command: command)
    }
    
    private func transferredChatEvent(tags: String?, reservedUserId: String?, reservedGroupId: String?) {
        let command = Command(eventType: .transferredChat)
        if let tags = tags {
            command.addParam(key: .eventTags, value: tags)
        }
        if let reservedUserId = reservedUserId {
            command.addParam(key: .eventReservedUserId, value: reservedUserId)
        }
        if let reservedGroupId = reservedGroupId {
            command.addParam(key: .eventReservedGroupId, value: reservedGroupId)
        }
        self.addCommandToQueue(command: command)
    }
    
    private func banInterlocutorEvent() {
        self.addCommandToQueue(command: Command(eventType: .bannedInterlocutor))
    }
    
    private func voteEvent() {
        self.addCommandToQueue(command: Command(eventType: .votedChat))
    }
    
    private func notifiedAbuseEvent(interlocutorIds: String, email: String, comment: String, completion: @escaping AbuseCompletionHandler) {
        let command = Command(eventType: .notifiedAbuse)
        command.addParam(key: .eventComment, value: comment)
        command.addParam(key: .eventEmail, value: email)
        command.addParam(key: .eventTargetUserIds, value: interlocutorIds)
        command.completionHandler = { (result, completed) in
            completed()
            if let result = result {
                if let accepted = result["accepted"] as? Bool, accepted == true {
                    completion(true, .none)
                }
                else {
                    let errorType = AbuseErrorType(rawValue: result["error"] as? String ?? "") ?? .none
                    completion(false, errorType)
                }
            }
        }
        
        self.addCommandToQueue(command: command)
    }
        
    // MARK: - Conversion
    
    class func conversion(hostId: String, name: String, purchaseParameters: PurchaseParameters?) {
        if let hostSessionId = UserDefaults.standard.string(forKey: Constants.Keys.hostSessionId), let secureApiHost = Session.shared.secureApiHost {
            var requestUrl = "\(secureApiHost)/trackers/conversion.png?"
            requestUrl += "hostMnemonic=\(hostId)&"
            requestUrl += "type=\(name)&"
            requestUrl += "sessionId=\(hostSessionId)&"
            
            if let purchaseParameters = purchaseParameters {
                requestUrl += "isNewBuyer=\(purchaseParameters.newBuyer ? "true" : "false")&"
                requestUrl += "purchaseId=\(purchaseParameters.purchaseId)&"
                requestUrl += "valueAmount=\(String(purchaseParameters.valueAmount))&"
                requestUrl += "valueCurrency=\(String(purchaseParameters.valueCurrency.value))&"
            }
            
            cDebug("Conversion \(requestUrl)")
            
            let session = widgetUrlSession()
            if let url = URL(string: requestUrl) {
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    cDebug("Conversion tag sent")
                }).resume()
            }
        }
    }
    
}
 
