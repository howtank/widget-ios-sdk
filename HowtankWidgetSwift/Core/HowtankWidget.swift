//
//  HowtankWidget.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 30/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public class HowtankWidget : NSObject, ClosedWidgetViewDelegate, ExpandedWidgetViewDelegate {    
    // MARK: - Properties
    
    private var hostId: String?
    private var delegate: HowtankWidgetDelegate?
    
    private var hidden = true // widget is hidden by default
    private var active = false
    private var expanded = false
    private var chatStarted = false
    
    private var disableTimeInSeconds: Double = 1800
    private var disableRequiredValidation = false
    
    private var keyboardHeight: CGFloat = 0
    
    private var window: UIWindow?
    
    private var chat: Chat?
    
    // Current page
    private var pageName: String?
    private var pageUrl: String?
    
    // Views
    private var closedWidgetView: ClosedWidgetView?
    private var closedWidgetFrame: CGRect?
    private var closeAreaView: CloseAreaView?
    private var closeAreaBackgroundView: UIView?
    private var expandedWidgetView: ExpandedWidgetView?
    private var expandedWidgetBackgroundView: UIView?
    
    private(set) var verboseMode: Bool = false
    
    // MARK: - Constants
    
    private let closeAreaViewHeight: CGFloat = 120
    
    
    // MARK: - Singleton
    
    private override init() {
        super.init()
        // Add observers to handle keyboard notifications
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // Remove keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Widget instance
    @objc public static let shared = HowtankWidget()
    
    // MARK: - Widget public methods
    
    /// Set the widget host id and delegate. This method is mandatory and should be called last
    @objc public func configure(hostId: String, delegate: HowtankWidgetDelegate?) {
        self.active = false
        
        self.hostId = hostId
        self.delegate = delegate
        
        // If session has not been initialized, do it
        if Session.shared.secureApiHost == nil {
            _ = self.usingSandboxPlatform(false)
        }
        
        // Check if widget is disabled
        if !enabled() {
            delegate?.widgetEvent(event: .unavailable, paramaters: ["reason": "Widget disabled"])
            return
        }
        
        
        guard let window = UIApplication.shared.keyWindow else {
            cDebug("Window is not initialized yet. Will retry in a second.")
            Utility.delay(1, closure: {
                self.configure(hostId: hostId, delegate: delegate)
            })
            return
        }
        self.window = window
        
    }
    
    /// Set to true if you want to use the integration platform
    @objc public func usingSandboxPlatform(_ sandboxPlatform: Bool) -> HowtankWidget {
        Session.shared.configure(secureApiHost: sandboxPlatform ? Constants.Api.Sandbox.secureHost : Constants.Api.Production.secureHost,
                                 secureCdnHost: sandboxPlatform ? Constants.Api.Sandbox.secureCdnHost : Constants.Api.Production.secureCdnHost)
        return self
    }
    
    /// Set verbose mode
    @objc public func verboseMode(_ verbose: Bool) -> HowtankWidget {
        self.verboseMode = verbose
        return self
    }
    
    /// Update widget visibility. Decide wether or not widget is discreet
    @objc public func browse(show: Bool = true, pageName: String, pageUrl: String? = nil, position: String? = nil) {
        guard self.window != nil else {
            // If window is not yet initialized, wait for a bit
            Utility.delay(1, closure: {
                self.browse(show: show, pageName: pageName, pageUrl: pageUrl, position: position)
            })
            return
        }
        
        self.pageName = pageName
        self.pageUrl = pageUrl
        
        self.hidden = !show
        self.showOrHide()
        
        self.chat?.browsePage(name: pageName, url: pageUrl)
        
        if (show || chatStarted), Theme.shared.setCustomPositionAndReturnIfChanged(position) {
            self.closedWidgetView?.setPosition()
        }
    }
    
    /// Open the widget chat window. If the widget is not enabled, nothing happens
    @objc public func open() {
        if self.enabled(), self.active {
            self.widgetShouldExpand()
        }
    }
    
    /// Remove created widget from superview
    @objc public func remove() {
        if self.hostId != nil {
            self.closedWidgetView?.removeFromSuperview()
            self.closedWidgetView = nil
            
            self.expandedWidgetView?.removeFromSuperview()
            self.expandedWidgetView = nil
            
            self.chat = nil
        }
    }
    
    /// Collapse widget (close the chat window)
    @objc public func collapse() {
        // Collapse widget
        if self.expanded {
            self.expandedWidgetView?.collapse()
        }
    }
    
    /// Send a conversion tag to Howtank
    @objc public func conversion(name: String, purchaseParameters: PurchaseParameters? = nil) {
        guard let hostId = hostId else {
            return
        }
        Chat.conversion(hostId: hostId, name: name, purchaseParameters: purchaseParameters)
    }
    
    // MARK: - Customization
    
    /// Set custom font name and bold font name (optional) to be used for the widget
    @objc public func customFont(fontName: String, boldFontName: String? = nil) -> HowtankWidget {
        Theme.shared.setCustomFont(fontName: fontName, boldFontName: boldFontName)
        return self
    }
    
    /// Set optional custom images for inactive and active chat states. Images should be 30x30
    @objc public func customImages(inactiveImage: UIImage? = nil, activeImage: UIImage? = nil) -> HowtankWidget {
        Theme.shared.setCustomImages(inactiveImage: inactiveImage, activeImage: activeImage)
        return self
    }
    
    @objc public func configTheme(theme: Theme) {
        Theme.shared.fill(theme: theme)
    }
    
    // MARK: - Widget disability
    
    /// Checks of the widget is enabled. Widget can be disabled by dragging it in the "clear" circle.
    @objc public func enabled() -> Bool {
        if let deletedDate = UserDefaults.standard.object(forKey: Constants.Keys.deletedDate) as? Date {
            let timeInterval = Date().timeIntervalSince(deletedDate)
            if disableTimeInSeconds > -1, timeInterval > disableTimeInSeconds {
                cDebug(verbose: true, "Widget has been disabled for \(timeInterval) but disable time is \(disableTimeInSeconds). Enabling widget.")
                UserDefaults.standard.removeObject(forKey: Constants.Keys.deletedDate)
                UserDefaults.standard.synchronize()
                return true
            }
            else {
                if disableTimeInSeconds == -1 {
                    cDebug(verbose: true, "Widget is disabled until manual reactivation")
                }
                else {
                    cDebug(verbose: true, "Widget is disabled for \(disableTimeInSeconds - timeInterval) more seconds")
                }
                return false
            }
        }
        return true
    }
    
    /// Enable widget if it was previously disabled.
    @objc public func enable() {
        if !self.enabled() {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.deletedDate)
            UserDefaults.standard.synchronize()
            
            if let hostId = hostId {
                self.configure(hostId: hostId, delegate: self.delegate)
                self.showOrHide()
            }
        }
    }
    
    /// Disable widget. Widget will never be shown again unless enabled.
    @objc public func disable() {
        if self.enabled() {
            UserDefaults.standard.set(Date(), forKey: Constants.Keys.deletedDate)
            UserDefaults.standard.synchronize()
            
            self.remove()
            
            self.delegate?.widgetEvent(event: .disabled, paramaters: nil)
        }
    }
    
    /// Set the number of minutes the widget will be disabled when removed by the user
    @objc public func widgetDisabledTime(minutes: Int) -> HowtankWidget {
        self.disableTimeInSeconds = Double(minutes) * 60
        return self
    }
    
    /// Set the number of days the widget will be disabled when removed by the user
    @objc public func widgetDisabledTime(days: Int) -> HowtankWidget {
        self.disableTimeInSeconds = Double(days) * 86400
        return self
    }
    
    /// Set the widget to be disabled forever (until manually activated) when removed by the user
    @objc public func widgetDisabledTimeForever() -> HowtankWidget {
        self.disableTimeInSeconds = -1
        return self
    }
    
    /// Set if disabling the widget requires user validation
    @objc public func disablingWidgetRequiresValidation(_ requiresValidation: Bool) -> HowtankWidget {
        self.disableRequiredValidation = requiresValidation
        return self
    }
    
    // MARK: - Keyboard functions
    
    @objc func keyboardWillChangeFrame(_ notification: Notification)
    {
        if let window = self.window {
            self.keyboardHeight = notification.keyboardHeight(forView: window)
            self.repositionExpandedView()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        self.keyboardHeight = 0
        self.repositionExpandedView()
    }
    
    // MARK: - Utuility methods
    
    private func initChat() {
        // Only init chat if nil
        guard chat == nil, let hostId = self.hostId, let pageName = self.pageName, let window = self.window else {
            return
        }
        
        chat = Chat(hostId: hostId, pageName: pageName, pageUrl: pageUrl, completionHandler: { (active, error) in
            self.active = active
            if active {
                DispatchQueue.main.async {
                    self.delegate?.widgetEvent(event: .initialized, paramaters: nil)
                    
                    // Instantiate closed widget view
                    self.closedWidgetView = UINib.view(nibName: "HTClosedWidgetView", owner: self)
                    self.closedWidgetView?.delegate = self
                    
                    self.closeAreaView = UINib.view(nibName: "HTCloseAreaView", owner: self)
                    
                    self.closeAreaBackgroundView = UIView(frame: CGRect(x: 0, y: window.frame.height - self.closeAreaViewHeight, width: window.frame.width, height: self.closeAreaViewHeight))
                    // Set background gradient
                    let layer = CAGradientLayer()
                    layer.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: self.closeAreaViewHeight)
                    let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                    let color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                    layer.colors = [color1.cgColor, color2.cgColor]
                    self.closeAreaBackgroundView?.layer.insertSublayer(layer, at: 0)
                    
                    // Instantiate expanded widget view
                    // We do that now to avoid any lag later
                    DispatchQueue.global(qos: .background).async {
                        //                        // Instantiate nib in the background queue
                        let nib = ExpandedWidgetView.nib()
                        DispatchQueue.main.async {
                            let expandedView: ExpandedWidgetView? = nib.view(owner: self)
                            let expandedWidgetBackgroundView = UIView()
                            expandedWidgetBackgroundView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
                            expandedWidgetBackgroundView.frame = window.frame
                            expandedWidgetBackgroundView.translatesAutoresizingMaskIntoConstraints = false
                            expandedWidgetBackgroundView.alpha = 0
                            window.addSubview(expandedWidgetBackgroundView)
                            self.expandedWidgetBackgroundView = expandedWidgetBackgroundView
                            
                            let views = ["backgroundView": expandedWidgetBackgroundView]
                            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
                            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
                            
                            if let expandedWidgetView = expandedView {
                                expandedWidgetView.alpha = 0
                                expandedWidgetView.configure(delegate: self, chat: self.chat!)
                                
                                self.chat?.browsePage(name: pageName, url: self.pageUrl)
                                
                                expandedWidgetView.translatesAutoresizingMaskIntoConstraints = false
                                self.expandedWidgetView = expandedWidgetView
                                window.addSubview(expandedWidgetView)
                                
                                let views = ["expandedWidgetView" : expandedWidgetView]
                                window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[expandedWidgetView(530@750)]-(>=0)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
                                window.addConstraint(NSLayoutConstraint(item: expandedWidgetView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: window, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
                                let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(Constants.Dimensions.statusBarHeight))-[expandedWidgetView(926@750)]-(>=0)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
                                window.addConstraints(constraints)
                                expandedWidgetView.topLayoutConstraint = constraints[0]
                                expandedWidgetView.layer.shadowOffset = CGSize(width: 3, height: 2)
                                expandedWidgetView.layer.shadowRadius = 4
                                expandedWidgetView.layer.shadowColor = UIColor.black.cgColor
                                expandedWidgetView.layer.shadowOpacity = 0.6
                                
                                self.repositionExpandedView()
                            }
                        }
                    }
                    
                    // Preloads keyboard so there's no lag on initial keyboard appearance
                    let lagFreeField = UITextField()
                    window.addSubview(lagFreeField)
                    lagFreeField.becomeFirstResponder()
                    lagFreeField.resignFirstResponder()
                    lagFreeField.removeFromSuperview()
                    
                    self.showOrHide()
                }
            } // end if active
            else {
                cDebug("Widget is not available.")
                DispatchQueue.main.async {
                    self.delegate?.widgetEvent(event: .unavailable, paramaters: ["reason": error ?? ""])
                }
            }
        })
    }
    
    private func repositionExpandedView() {
        guard let window = self.window else {
            return
        }
        
        if window.frame.height - keyboardHeight >= 926 {
            self.expandedWidgetView?.topLayoutConstraint?.constant = (window.frame.size.height - keyboardHeight - 926) / 2
        }
        else if UIScreen.main.bounds.size.width <= 530 {
            self.expandedWidgetView?.topLayoutConstraint?.constant = 0
        }
        else {
            self.expandedWidgetView?.topLayoutConstraint?.constant = Constants.Dimensions.statusBarHeight
        }
    }
    
    private func showOrHide() {
        if hidden {
            if !chatStarted {
                self.hide()
                delegate?.widgetEvent(event: .hidden, paramaters: nil)
            }
            else {
                delegate?.widgetEvent(event: .displayed, paramaters: nil)
            }
        }
        else {
            guard self.window != nil else {
                cDebug("Window object is still nil, can't initialize chat")
                return
            }
            
            cDebug("Initializing chat")
            // Init chat if it's not already initialized
            self.initChat()
            
            self.show()
        }
    }
    
    private func show() {
        // Don't show if disabled
        guard self.enabled(), let closedWidgetView = self.closedWidgetView, let window = self.window,
              let closeAreaView = self.closeAreaView, let closeAreaBackgroundView = self.closeAreaBackgroundView else {
            return
        }
        
        self.hidden = false
        
        // If view has already been added, just show it
        if closedWidgetView.isDescendant(of: window) {
            if closedWidgetView.alpha != 1 {
                self.animateClosedWidgetView(show: true)
            }
        }
        else {
            closedWidgetView.configure(containerView: window, closeAreaView: closeAreaView, closeAreaBackgroundView: closeAreaBackgroundView)
            window.addSubview(closedWidgetView)
            self.closedWidgetFrame = closedWidgetView.frame
            self.animateClosedWidgetView(show: true)
            
            closeAreaView.center = CGPoint(x: window.frame.width / 2, y: window.frame.height + closeAreaView.frame.height / 2)
            closeAreaView.alpha = 0
            closeAreaBackgroundView.alpha = 0;
            window.addSubview(closeAreaView)
            window.addSubview(closeAreaBackgroundView)
        }
        window.bringSubviewToFront(closeAreaBackgroundView)
        window.bringSubviewToFront(closedWidgetView)
        window.bringSubviewToFront(closeAreaView)
        self.delegate?.widgetEvent(event: .displayed, paramaters: nil)
        
    }
    
    private func hide() {
        self.hidden = true
        
        if !chatStarted {
            animateClosedWidgetView(show: false)
        }
    }
    
    private func animateClosedWidgetView(show: Bool) {
        if let closedWidgetView = self.closedWidgetView {
            UIView.animate(withDuration: 0.2, animations: {
                closedWidgetView.alpha = show ? 1 : 0
            })
        }
    }
    
    // MARK: - ClosedWidgetViewDelegate methods
    
    func widgetShouldExpand() {
        guard let expandedWidgetView = self.expandedWidgetView,
              let expandedWidgetBackgroundView = self.expandedWidgetBackgroundView else {
            return
        }
        
        // Expand transition
        let expandedFrame = expandedWidgetView.frame
        self.closedWidgetFrame = closedWidgetView?.frame
        
        expandedWidgetView.expand(toFrame: expandedFrame)
        self.window?.bringSubviewToFront(expandedWidgetBackgroundView)
        self.window?.bringSubviewToFront(expandedWidgetView)
        expandedWidgetView.alpha = 0
        expandedWidgetBackgroundView.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0.25, options: .beginFromCurrentState, animations: {
            expandedWidgetView.alpha = 1
            expandedWidgetBackgroundView.alpha = 1
        }, completion: nil)
        
        self.expanded = true
        if let closedWidgetView = self.closedWidgetView {
            closedWidgetView.showExpandedMode(true, fromFrame: closedWidgetView.frame, toFrame: expandedFrame)
        }
        
        self.delegate?.widgetEvent(event: .opened, paramaters: nil)
    }
    
    func shouldDisableWidget(completion: @escaping (Bool) -> Void) {
        if disableRequiredValidation {
            let alertView = UIAlertController(title: nil, message: "widget.mobile.app.deletion.message".loc(), preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "widget.mobile.app.deletion.cancel".loc(), style: .cancel, handler: { (action) in
                completion(false)
            }))
            alertView.addAction(UIAlertAction(title: "widget.mobile.app.deletion.ok".loc(), style: .destructive, handler: { (action) in
                completion(true)
            }))
            Utility.topLevelViewController()?.present(alertView, animated: true, completion: nil)
        }
        else {
            completion(true)
        }
    }
    
    func widgetShouldBeRedrawn() {
        self.redrawWidget()
    }
    
    
    
    // MARK: - ExpandedWidgetViewDelegate methods
    
    public func expandedWidgetEvent(type: ExpandedWidgetEventType) {
        switch type {
            
        case .closed(chatView: _, chatClosed: let chatClosed):
            self.expandedCloseWidget(chatClosed: chatClosed)
            
        case .newChatMessage(chatView: _, message: _):
            if !self.expanded {
                self.closedWidgetView?.incrementChatCount()
            }
            
        case .userWriting(writing: let writing, distant: let distant):
            if distant && !self.expanded {
                // Display info that distant user is writing
                self.closedWidgetView?.distantUserWriting(writing)
            }
            
        case .linkSelected(link: let link):
            self.delegate?.widgetEvent(event: .linkSelected, paramaters: ["link": link])
            
        case .chatInitialized:
            self.chatStarted = true
            self.closedWidgetView?.chatStarted = true
            self.delegate?.widgetEvent(event: .calledInterlocutor, paramaters: nil)
            
        case .scoringInterlocutor:
            self.delegate?.widgetEvent(event: .scoringInterlocutor, paramaters: nil)
            
        case .thankingInterlocutor:
            self.delegate?.widgetEvent(event: .thankingInterlocutor, paramaters: nil)
            
        case .scoredInterlocutor(note: let note):
            self.delegate?.widgetEvent(event: .scoredInterlocutor, paramaters: ["note": note])
            
        case .thankedInterlocutor:
            self.delegate?.widgetEvent(event: .thankedInterlocutor, paramaters: nil)
            
        case .shouldRedrawWidget:
            self.redrawWidget()
            
        }
    }
    
    public func widgetShouldClose(chat: Chat, message: String, callback: () -> Void) -> Bool {
        return self.delegate?.widgetShouldClose(message: message, closeCallback: callback) ?? false
    }
    
    private func expandedCloseWidget(chatClosed: Bool) {
        if chatClosed {
            self.chatStarted = false
            self.closedWidgetView?.chatStarted = false
            self.delegate?.widgetEvent(event: .closed, paramaters: ["chatClosed": true])
        }
        else {
            self.delegate?.widgetEvent(event: .closed, paramaters: ["chatClosed": false])
        }
        
        // Close transition
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            self.expandedWidgetView?.alpha = 0
            self.expandedWidgetBackgroundView?.alpha = 0
        }) { (completed) in
            self.expandedWidgetView?.setNeedsLayout()
            self.expandedWidgetView?.layoutIfNeeded()
            self.showOrHide()
        }
        
        self.expanded = false
        if let closedWidgetView = self.closedWidgetView, let expandedWidgetView = self.expandedWidgetView, let closedWidgetFrame = self.closedWidgetFrame {
            closedWidgetView.showExpandedMode(false, fromFrame: expandedWidgetView.frame, toFrame: closedWidgetFrame)
        }
    }
    
    private func redrawWidget() {
        self.repositionExpandedView()
        self.closedWidgetView?.removeFromSuperview()
        Utility.delay(0.1) {
            self.showOrHide()
        }
    }
    
}
