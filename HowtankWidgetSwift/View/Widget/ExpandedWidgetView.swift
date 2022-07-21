//
//  ExpandedWidgetView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public protocol ExpandedWidgetViewDelegate {
    func expandedWidgetEvent(type: ExpandedWidgetEventType)
    func widgetShouldClose(message: String, callback: ()->Void) -> Bool
    
    // Expert actions
    func expertNibForShareChatCell() -> UINib?
    func expertMoreActionsView(chatView: ExpandedWidgetView) -> UIView?
    func showUser(user: User, hostId: String, imageView: UIImageView) -> Bool
    func keyboardFrameForNotification(notification: Notification) -> CGFloat?
    func autocompleteForMessage(_ message: String, hostId: String) -> String?
    func publicProfileUrl(userId: String, hostId: String) -> String?
    func tagsView(_ tagsView: UIView?, chatView: ExpandedWidgetView, tags: [String]) -> UIView?
}

extension ExpandedWidgetViewDelegate {
    public func widgetShouldClose(message: String, callback: ()->Void) -> Bool { return false }
    public func expertNibForShareChatCell() -> UINib? { return nil }
    public func expertMoreActionsView(chatView: ExpandedWidgetView) -> UIView? { return nil }
    public func showUser(user: User, hostId: String, imageView: UIImageView) -> Bool { return false }
    public func keyboardFrameForNotification(notification: Notification) -> CGFloat? { return nil }
    public func autocompleteForMessage(_ message: String, hostId: String) -> String? { return nil }
    public func publicProfileUrl(userId: String, hostId: String) -> String? { return nil }
    public func tagsView(_ tagsView: UIView?, chatView: ExpandedWidgetView, tags: [String]) -> UIView? { return nil }
}

public class ExpandedWidgetView: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
                ChatTableViewDataSourceDelegate, ChatDelegate, UITextViewDelegate,
                ThanksCellDelegate, ScoreCellDelegate,
                AbuseDisclaimerCellDelegate, AbuseCellDelegate, AbuseCompleteCellDelegate {

    // MARK: - IBOutlets
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tagsContainerView: UIView!
    @IBOutlet weak var tagsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewSeparator: UIView!
    
    @IBOutlet weak var textWrapperView: UIView!
    @IBOutlet weak var quitChatButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewPlaceholder: UILabel!
    @IBOutlet public weak var sendTextButton: UIButton!
    @IBOutlet public weak var moreActionsButton: UIButton!
    
    @IBOutlet weak var hostUserView: UIView!
    @IBOutlet weak var hostUserViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hostUserImageView: UIImageView!
    @IBOutlet weak var hostUserLabel: UILabel!
    
    @IBOutlet weak var completionView: UIView!
    @IBOutlet weak var completionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var completionCollectionView: UICollectionView!
    @IBOutlet weak var completionCommentView: UIView!
    @IBOutlet weak var completionTextView: UITextView!
    @IBOutlet weak var completionTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var completionPlaceholderLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var reduceButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
        
    // MARK: - Properties
    
    var topLayoutConstraint: NSLayoutConstraint?
    
    public private(set) var chat: Chat?
    private var delegate: ExpandedWidgetViewDelegate?
    
    private var chatDataSource = ChatTableViewDataSource()
    
    private var theme = Theme.shared
    
    private var expertUsersViews = [UserInfoView]()
    private var localIds = [NSNumber]()
    
    // Original frame for widget move
    private var originalFrame: CGRect?
    private var previousWindowWidth: CGFloat?
    
    // Links
    private var detectedLinks = [NSValue: String]()
    
    private var lastScrolledIndexPath: Int?
    private var thanksCellIndexPath: Int?
    private var scoreCellIndexPath: Int?
    private var firstAbuseCellIndexPath: Int?
    private var abuseCell: AbuseCell?
    private var indexPathBeforeAbuse: Int? // Referenced indexPath before abuse is clicked
    
    private var shareChatEventAdded = false
    
    private var hostUserProfileUrl: URL?
    
    // Expert mode
    private var spectator = false
    private var expertMode = false
    private var expertInitialization = false
    private var customInputView: UIView?
    private var tagsView: UIView?
    
    // Keyboard
    private var keyboardDisplayed = false
    private var keyboardHeight: CGFloat = 0
    
    // Views
    private var expertButton: UIButton?
    private var imageView: ImageView?
    
    // Expert
    public var leftLayoutConstraint: NSLayoutConstraint?
    public var widthLayoutConstraint: NSLayoutConstraint?
        
    // MARK: - Lifecycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Add observers to handle keyboard notifications
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.previousWindowWidth = self.window?.frame.width
        
        // Register nibs
        let howtankBundle = Bundle.howtankBundle(owner: self)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTSentMessageCell", identifier: "sentMessageCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTReceivedMessageCell", identifier: "receivedMessageCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTChatMessageCell", identifier: "chatMessageCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTSentImageCell", identifier: "sentImageCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTReceivedImageCell", identifier: "receivedImageCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTSpecialEventCell", identifier: "specialEventCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTBrowsedUrlCell", identifier: "browsedUrlCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTChatDistantUserCell", identifier: "chatDistantUserCell", bundle: howtankBundle)
        self.chatsTableView.registerNibForIdentifier(nibName: "HTChatLocalUserCell", identifier: "chatLocalUserCell", bundle: howtankBundle)
        
        self.chatsTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        
        // Nibs for completion collection view
        self.completionCollectionView.registerNibForIdentifier(nibName: "HTScoreCell", identifier: "scoreCell", bundle: howtankBundle)
        self.completionCollectionView.registerNibForIdentifier(nibName: "HTThanksCell", identifier: "thanksCell", bundle: howtankBundle)
        // Nibs for abuse
        self.completionCollectionView.registerNibForIdentifier(nibName: "HTAbuseDisclaimerCell", identifier: "abuseDisclaimerCell", bundle: howtankBundle)
        self.completionCollectionView.registerNibForIdentifier(nibName: "HTAbuseCell", identifier: "abuseCell", bundle: howtankBundle)
        self.completionCollectionView.registerNibForIdentifier(nibName: "HTAbuseCompleteCell", identifier: "abuseCompleteCell", bundle: howtankBundle)
        
        self.completionCollectionView.backgroundColor = UIColor.white
        
         // Colors and Fonts
        self.topView.backgroundColor = theme.color(.theme)
        self.sendTextButton.tintColor = theme.color(.active)
        self.moreActionsButton.tintColor = theme.color(.active)
        self.quitChatButton.tintColor = theme.color(.active)
        self.textViewPlaceholder.textColor = Theme.grayText
        self.textViewSeparator.backgroundColor = Theme.grayText
        self.introLabel.textColor = theme.color(.introText)
        self.topViewTitle.textColor = theme.color(.themeText)
        self.topViewTitle.font = theme.fontOfSize(self.topViewTitle.font.pointSize)
        self.textViewPlaceholder.font = theme.fontOfSize(self.textViewPlaceholder.font.pointSize)
        self.infoLabel.font = theme.fontOfSize(self.infoLabel.font.pointSize)
        self.backButton.setTitleColor(theme.color(.themeText), for: .normal)
        self.closeButton.tintColor = theme.color(.themeText)
        self.reduceButton.tintColor = theme.color(.themeText)
        self.activityIndicator.isHidden = true
        
        self.textView.layer.borderColor = theme.color(.active).cgColor
        self.textView.layer.borderWidth = 2
        self.textView.layer.cornerRadius = 19
        self.textView.textContainer.lineFragmentPadding = 10
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 4, bottom: 11, right: 4)
        
        // Translations
        self.topViewTitle.text = "widget.title".loc()
        self.quitChatButton.setTitle("app.chat.quit".loc(), for: .normal)
        
        self.sendTextButton.layer.cornerRadius = self.sendTextButton.frame.size.height / 2
        
        // Set line spacing for intro
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        let attributedString = NSMutableAttributedString(string: "widget.intro".loc())
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(.font, value: theme.boldFontOfSize(self.introLabel.font.pointSize), range: NSMakeRange(0, attributedString.length))
        self.introLabel.attributedText = attributedString
        self.textViewPlaceholder.text = "widget.placeholder.askquestion".loc()
        
        // Instantiate chat
        self.chatDataSource.delegate = self
        self.chatsTableView.dataSource = self.chatDataSource
        self.chatsTableView.delegate = self.chatDataSource
        
        // Gesture recognizers
        self.topView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panView(sender:))))
        self.infoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoLabelTapped(sender:))))
    }
    
    deinit {
        // Remove keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.chatsTableView.delegate = nil
        self.chatsTableView.dataSource = nil
    }
    
    // TODO later we could paste images
    //- (void)paste:(id)sender {
    //    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    //    HTDebug(@"Image %@", [gpBoard image]);
    //}
    
    public class func nib() -> UINib {
        return UINib.howtankNib(name: "HTExpandedWidgetView", owner: self)
    }
        
    // MARK: - Configuration
    
    func configure(delegate: ExpandedWidgetViewDelegate, chat: Chat) {
        self.delegate = delegate
        self.chat = chat
    }
    
    public func configureExpertMode(expertChat: ExpertChat, authorization: String?, delegate: ExpandedWidgetViewDelegate) -> Chat {
        self.expertMode = true
        self.expertInitialization = true
        self.chatDataSource.expertMode = true
        self.refreshTheme(expertChat.theme)
        
        self.chatDataSource.communityMemberLabel = expertChat.communityMemberLabel
        self.chatDataSource.supportAgentLabel = expertChat.supportAgentLabel
        
        self.delegate = delegate
        self.spectator = expertChat.spectator
        
        // Expert mode has no titleBar
        self.hostUserViewTopConstraint.constant = -(64 + self.hostUserView.frame.height)
        self.hostUserView.isHidden = true
        
        // Add share chat cell
        if let shareChatCellXib = self.delegate?.expertNibForShareChatCell() {
            self.chatsTableView.register(shareChatCellXib, forCellReuseIdentifier: "shareChatCell")
        }
        
        self.initFrame(frame: self.frame)
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        // Hides a bunch of views
        self.completionView.isHidden = true
        self.introView.isHidden = true
        self.textViewPlaceholder.isHidden = true
        self.infoLabel.text = ""
        self.infoLabel.isHidden = true
        self.topView.isHidden = true
        
        self.chatsTableView.isHidden = false
        
        self.backgroundColor = self.theme.color(.background)
        self.textViewSeparator.isHidden = !self.spectator
        
        // Initialize chat
        self.chat = Chat(delegate: self, expertChat: expertChat, authorization: authorization)
        
        if !self.spectator && !expertChat.closed {
            self.textView.becomeFirstResponder()
        }
        else {
            self.textView.isEditable = false
            self.textView.text = ""
            self.resizeTextView(force: false)
            self.textView.isHidden = true
            self.sendTextButton.isHidden = true
            
            self.moveBottomViewWithDuration(duration: 0)
        }
        
        // Handle buttons display
        self.quitChatButton.isHidden = !self.spectator
        self.textViewSeparator.isHidden = !self.spectator
        self.moreActionsButton.isHidden = self.spectator
        self.textViewLeftConstraint.constant = self.spectator ? 5 : 45
        
        self.chatsTableView.reloadData()
        
        // Add gesture recognizer for host user view
        self.hostUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hostUserProfileUrlTapped(sender:))))
        
        return self.chat!
    }
        
    // MARK - Expand view
    
    func expand(toFrame: CGRect) {
        if chat?.delegate == nil {
            // Initialize chat and default views
            self.chat?.configure(delegate: self)

            self.chatsTableView.isHidden = true
            self.introView.isHidden = false
            self.infoLabel.isHidden = false

            // Detect links and replace them
            // BEGIN link detection
            let originalIntroText = "widget.disclaimer".loc()
            let introText = (originalIntroText as NSString).mutableCopy() as! NSMutableString
            let linkRegExp = try! NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>(.*)?</a>", options: [.caseInsensitive])

            self.detectedLinks = [NSValue: String]()
            var offset = 0 // keeps track of range changes in the string
            linkRegExp.matches(in: introText as String, options: [], range: NSMakeRange(0, (introText as NSString).length)).forEach({ (result) in
                var resultRange = result.range
                resultRange.location += offset

                let replacement = linkRegExp.replacementString(for: result, in: introText as String, offset: offset, template: "$2")
                // Make the replacement
                introText.replaceCharacters(in: resultRange, with: replacement)

                let detectedRange = NSMakeRange(resultRange.location, (replacement as NSString).length)
                self.detectedLinks[NSValue(range: detectedRange)] = (originalIntroText as NSString).substring(with: result.range(at: 1))

                // update the offset based on the replacement
                offset += (replacement as NSString).length - resultRange.length
            })

            let attributedString = NSMutableAttributedString(string: introText as String)
            self.detectedLinks.forEach({ (detectedLink) in
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: detectedLink.key.rangeValue)
            })
            // END link detection

            self.infoLabel.attributedText = attributedString
            self.infoLabel.textColor = theme.color(.disclaimerText)
            self.backgroundColor = theme.color(.introBackground)
            self.textViewSeparator.isHidden = true
            self.textView.isEditable = true
            self.textView.text = ""
            self.textViewPlaceholder.isHidden = false
            self.completionView.isHidden = true
            self.completionCommentView.isHidden = true
            self.backButton.alpha = 0
            self.closeButton.alpha = 1
            self.thanksCellIndexPath = nil
            self.scoreCellIndexPath = nil
            self.firstAbuseCellIndexPath = nil
            if ((self.chat?.supportInterlocutors.count ?? 0) + (self.chat?.communityInterlocutors.count ?? 0)) > 0 {
                self.lastScrolledIndexPath = 0
                self.scrollToItem()
            }

            self.textWrapperView.backgroundColor = theme.color(.introBackground)
            self.textView.backgroundColor = UIColor.white
            self.textView.layer.borderColor = theme.color(.introText).cgColor
            self.sendTextButton.tintColor = theme.color(.introText)

            // Hide expert actions for users
            self.quitChatButton.isHidden = true
            self.moreActionsButton.isHidden = true

            // Hide host user view
            self.hostUserViewTopConstraint.constant = -self.hostUserView.frame.height
            self.hostUserView.isHidden = true

            self.resizeTextView(force: false)
            self.moveBottomViewWithDuration(duration: 0)

            self.chatsTableView.reloadData()

            self.shareChatEventAdded = false
        }
        
        self.initFrame(frame: frame)
    }
    
    private func initFrame(frame: CGRect) {
        self.frame = frame
        self.layoutIfNeeded()
        self.chatDataSource.tableWidth = self.chatsTableView.frame.width
        
        self.infoLabel.preferredMaxLayoutWidth = frame.size.width - 20
    }
        
    // MARK: - IBActions
    
    @IBAction func closeWidget(_ sender: Any) {
        UIApplication.hideKeyboard()
        
        // We display an alert if chat has already been started
        if (self.chat?.status == .calling || self.chat?.status == .joined), !self.spectator {
            if !(self.delegate?.widgetShouldClose(message: "widget.mobile.app.close.disclaimer.message".loc(), callback: {
                self.closeWidgetAction()
            }) ?? false) {
                self.alertForClosingChat()
            }
        }
        else {
            self.closeWidgetAction()
        }
    }
    
    func collapse() {
        self.collapseWidget(self)
    }
    
    @IBAction func collapseWidget(_ sender: Any) {
        UIApplication.hideKeyboard()
        self.delegate?.expandedWidgetEvent(type: .closed(chatView: self, chatClosed: false))
    }
    
    @IBAction func cancelCloseAction(_ sender: Any) {
        let originalFrame = self.completionView.frame
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.completionView.frame = CGRect(x: self.completionView.frame.origin.x + self.completionView.frame.width, y: self.completionView.frame.origin.y, width: self.completionView.frame.width, height: self.completionView.frame.height)
        }) { (completed) in
            self.completionView.frame = originalFrame
            self.completionView.isHidden = true
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = self.textView.text.trimmingCharacters(in: .whitespaces)
        if message.count > 0 {
            // Empty textView
            self.textView.text = ""
            self.resizeTextView(force: false)
            
            self.chat?.wroteMessage(message)
        }
    }
    
    @IBAction func moreActions(_ sender: Any) {
        self.customInputView = self.delegate?.expertMoreActionsView(chatView: self)
        
        let hasInputView = self.textView.inputView != nil
        self.toggleMoreActions(show: !hasInputView)
        
        self.textView.reloadInputViews()
        self.textView.becomeFirstResponder()
    }
    
    private func toggleMoreActions(show: Bool) {
        self.textView.inputView = show ? self.customInputView : nil
        UIView.animate(withDuration: 0.3, animations: {
            self.moreActionsButton.transform = show ? CGAffineTransform(rotationAngle: 45 * CGFloat.pi / 180) : CGAffineTransform(rotationAngle: 0)
        })
    }
        
    // MARK: - Close actions
    
    private func closeWidgetAction() {
        UIApplication.hideKeyboard()
        
        // Display completion view
        if !self.expertMode, completionView.isHidden, let chat = self.chat, (chat.communityInterlocutors.count > 0 || chat.supportInterlocutors.count > 0), chat.status != .closed {
            chat.willScoreInterlocutor()
            
            // Calculate index paths
            self.thanksCellIndexPath = chat.communityInterlocutors.count > 0 ? 0 : nil
            self.scoreCellIndexPath = chat.supportInterlocutors.count > 0 ? 1 + (self.thanksCellIndexPath ?? -1) : nil
            self.firstAbuseCellIndexPath = chat.communityInterlocutors.count > 0 && chat.supportInterlocutors.count > 0 ? 2 : 1
            
            if completionCollectionView.numberOfItems(inSection: 0) > 0 {
                self.lastScrolledIndexPath = 0
                self.scrollToItem()
            }
            
            // Send analytics
            if self.thanksCellIndexPath != nil {
                self.delegate?.expandedWidgetEvent(type: .thankingInterlocutor)
            }
            else {
                self.delegate?.expandedWidgetEvent(type: .scoringInterlocutor)
            }
            
            self.completionView.superview?.layoutIfNeeded()
            (self.completionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: self.frame.width, height: self.completionCollectionView.frame.height)
            self.completionCollectionView.reloadData()
            self.completionView.isHidden = false
            
            let finalFrame = completionView.frame
            self.completionView.frame = CGRect(x: self.completionView.frame.origin.x, y: self.completionView.frame.origin.y - self.completionView.frame.height, width: self.completionView.frame.width, height: self.completionView.frame.height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                self.completionView.frame = finalFrame
            }, completion: nil)
        }
        else {
           // Close chat session
            self.chat?.closeChat()
            self.chat?.delegate = nil
            self.chatDataSource.reset()
            self.chatsTableView.subviews.forEach({ (view) in
                if view is UIButton {
                    view.removeFromSuperview()
                }
            })
            self.expertUsersViews.forEach({ (view) in
                view.removeFromSuperview()
            })
            self.expertUsersViews.removeAll()
            self.delegate?.expandedWidgetEvent(type: .closed(chatView: self, chatClosed: true))
            if self.expertMode, self.spectator {
                self.chat = nil
            }
        }
    }
    
    private func alertForClosingChat() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindow.Level.alert + 1
        
        let alertController = UIAlertController(title: nil, message: "widget.mobile.app.close.disclaimer.message".loc(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "widget.mobile.app.close.disclaimer.cancel".loc(), style: .cancel, handler: { (action) in
            window.isHidden = true
        }))
        alertController.addAction(UIAlertAction(title: "widget.mobile.app.close.disclaimer.ok".loc(), style: .destructive, handler: { (action) in
            window.isHidden = true
            self.closeWidgetAction()
        }))
        
        window.makeKeyAndVisible()
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }
        
    // MARK: - Gesture actions
    
    @objc func panView(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.originalFrame = self.frame
            UIApplication.hideKeyboard()
        }
        else if sender.state == .changed, let originalFrame = self.originalFrame {
            self.frame = CGRect(x: originalFrame.origin.x, y: originalFrame.origin.y + sender.translation(in: self.superview!).y, width: self.frame.width, height: self.frame.height)
        }
        else if sender.state == .ended, let originalFrame = self.originalFrame {
            let translation = sender.translation(in: self.superview!).y
            let velocity = sender.velocity(in: self.superview!).y
            if velocity > 1000 || (velocity > 0 && translation > self.superview!.frame.height / 2) {
                self.delegate?.expandedWidgetEvent(type: .closed(chatView: self, chatClosed: false))
            }
            else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                    self.frame = originalFrame
                }, completion: nil)
            }
        }
    }
    
    @objc func userSelected(button: UIButton) {
        let user = self.chatDataSource.expertUsers[button.tag]
        self.userSelected(user: user, imageView: button.imageView!, fromFrame: button.frame, view: self.chatsTableView)
    }
    
    @objc func infoLabelTapped(sender: UITapGestureRecognizer) {
        if self.detectedLinks.count > 0, let textLabel = sender.view as? UILabel {
            let tapLocation = sender.location(in: textLabel)
            
            // Init text storage
            let textStorage = NSTextStorage(attributedString: textLabel.attributedText!)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            
            // Init text container
            let textContainer = NSTextContainer(size: CGSize(width: textLabel.frame.width, height: textLabel.frame.height + 100))
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = textLabel.numberOfLines
            textContainer.lineBreakMode = textLabel.lineBreakMode
            
            layoutManager.addTextContainer(textContainer)
            
            let characterIndex = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            self.detectedLinks.forEach({ (detectedLink) in
                let linkRange = detectedLink.key.rangeValue
                if characterIndex >= linkRange.location, characterIndex <= linkRange.location + linkRange.length {
                    // Open link
                    if let url = URL(string: detectedLink.value) {
                        UIApplication.shared.open(url)
                    }
                }
            })
        }
    }
    
    
    @objc func hostUserProfileUrlTapped(sender: UITapGestureRecognizer) {
        if let hostUserProfileUrl = self.hostUserProfileUrl {
            UIApplication.shared.open(hostUserProfileUrl)
        }
    }
    
    
    private func scrollToItem() {
        if let lastScrollIndexPath = self.lastScrolledIndexPath {
            DispatchQueue.main.async {
                self.completionCollectionView.scrollToItem(at: IndexPath(item: lastScrollIndexPath, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
            }
        }
    }
        
    // MARK: - Keyboard functions
    
    @objc func keyboardWillChangeFrame(_ notification: Notification)
    {
        self.keyboardDisplayed = true
        
        self.keyboardHeight = self.delegate?.keyboardFrameForNotification(notification: notification) ?? notification.keyboardHeight(forView: self)
        if #available(iOS 11.0, *) {
            self.bottomViewBottomConstraint.constant = self.keyboardHeight + self.safeAreaInsets.bottom
            self.completionViewBottomConstraint.constant = self.keyboardHeight + self.safeAreaInsets.bottom
        }
        else {
            self.bottomViewBottomConstraint.constant = self.keyboardHeight
            self.completionViewBottomConstraint.constant = self.keyboardHeight
        }
        
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
        
        self.resizeTextView(force: true)
        self.scrollToTableBottom()
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        self.keyboardDisplayed = false
        self.keyboardHeight = 0
        
        self.toggleMoreActions(show: false)
        self.moveBottomViewWithDuration(duration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0)
    }
    
    private func moveBottomViewWithDuration(duration: TimeInterval) {
        let constraint = (self.textView.isEditable || self.expertMode) ? 0 : -(self.textWrapperView.frame.height + 0.5)
        if #available(iOS 11.0, *) {
            self.bottomViewBottomConstraint.constant = constraint + self.safeAreaInsets.bottom
            self.completionTextViewBottomConstraint.constant = self.safeAreaInsets.bottom
        } else {
            self.bottomViewBottomConstraint.constant = constraint
            self.completionTextViewBottomConstraint.constant = 0
        }
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
            self.textWrapperView.alpha = (self.textView.isEditable || self.expertMode) ? 1 : 0
        }
    }
    
    private func resizeTextView(force: Bool) {
        let fixedWidth = self.textView.frame.width
        let newSize = self.textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if force || newSize.height != self.textViewHeightConstraint.constant {
            self.textViewHeightConstraint.constant = min(self.frame.size.height - self.keyboardHeight - 150, newSize.height)
            // Allow scroll if text area is too big
            self.textView.isScrollEnabled = newSize.height != self.textViewHeightConstraint.constant
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }, completion: { (completed) in
                self.scrollToTableBottom()
            })
        }
    }
        
    // MARK: - UITextViewDelegate methods
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.completionTextView {
            if text == "\n" {
                self.textView.resignFirstResponder()
                self.abuseCell?.updateComment(self.textView.text)
                self.completionCommentView.isHidden = true
                return false
            }
            else {
                self.completionPlaceholderLabel.isHidden = !(range.location == 0 && text.count == 0)
            }
            return true
        }
        else {
            if text == "\n" {
                self.sendMessage(textView)
                return false
            }
            else {
                self.textViewPlaceholder.isHidden = self.expertMode || !(chat?.status == .opened && range.location == 0 && text.count == 0)
                self.chat?.writingMessage()
                
                if self.expertMode, text == " " {
                    if let sentence = self.delegate?.autocompleteForMessage(textView.text, hostId: self.chat!.hostId) {
                        textView.text = textView.text + " \(sentence)"
                        
                        let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + text.count)!
                        textView.selectedTextRange = textView.textRange(from: startPosition, to: textView.endOfDocument)
                        return false
                    }
                }
            }
            return true
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.resizeTextView(force: false)
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        self.resizeTextView(force: false)
    }
        
    // MARK: - ChatTableViewDataSourceDelegate methods
    
    func currentChat() -> Chat? {
        return self.chat
    }
    
    func linkSelected(_ link: String) {
        self.delegate?.expandedWidgetEvent(type: .linkSelected(link: link))
    }
    
    func userSelected(_ user: User, imageView: UIImageView, cellFrame: CGRect) {
        self.userSelected(user: user, imageView: imageView, fromFrame: cellFrame, view: self.chatsTableView)
    }
    
    func willZoomImage(imageView: UIImageView) {
        // Hide keyboard
        self.textView.resignFirstResponder()
        if self.imageView == nil {
            self.imageView = UINib.view(nibName: "HTImageView", owner: self)
            self.imageView!.frame = self.bounds
            self.imageView!.isHidden = true
            self.addSubview(self.imageView!)
            self.bringSubviewToFront(self.imageView!)
        }
        let newOrigin = imageView.convert(CGPoint.zero, to: self)
        self.imageView?.display(image: imageView.image, fromFrame: CGRect(x: newOrigin.x, y: newOrigin.y, width: imageView.frame.width, height: imageView.frame.height))
    }
        
    // MARK: - ChatDelegate methods
    
    func chatEvent(type: ChatEventType) {
        switch type {
            
        case .chatMessage(let message, local: let local):
            if let localId = message.localId {
                if local {
                    self.localIds.append(localId)
                }
                else {
                    // First we check if the message is not already displayed
                    if message.type == .wroteMessage, self.localIds.contains(localId) {
                        return
                    }
                }
            }
            
            if !message.belongsToUser {
                if !expertMode {
                    message.user = self.chatDataSource.expertUsers.last
                }
            }
            else {
                if expertMode {
                    message.user = self.chatDataSource.expertUsers.last
                }
            }
            
            // Message can be empty if it's just an image
            if message.content?.count ?? 0 > 0 {
                self.addEventToDataSource(message)
            }
            
            // If any detected images
            message.detectedImagesUrls?.forEach({ (url) in
                DispatchQueue.global(qos: .background).async {
                    if let image = ImageService.animatedImageWithGifUrl(url: url) {
                        // Make a trivial (1x1) graphics context, and draw the image into it
                        // We do that before setting image in the main thread
                        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
                        let context = UIGraphicsGetCurrentContext()
                        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
                        UIGraphicsEndImageContext()
                    
                        let imageEvent = Event(image: image, user: message.user)
                        self.addEventToDataSource(imageEvent)
                    }
                }
            })
            
        case .userJoined(let user):
            self.chatDataSource.expertUsers.append(user)
            
            DispatchQueue.main.async {
                self.introView.isHidden = true
                self.infoLabel.text = ""
                self.infoLabel.isHidden = true
                
                // Create expert view
                let expertUserView: UserInfoView = UINib.view(nibName: "HTUserInfoView", owner: self)!
                self.expertUsersViews.append(expertUserView)
                expertUserView.refresh(user: user, frame: self.bounds, topViewHeight: self.topViewHeightConstraint.constant)
                expertUserView.isHidden = true
                self.addSubview(expertUserView)
                self.bringSubviewToFront(expertUserView)
                
                // Add button
                let buttonSize = CGFloat(33)
                let buttonX = self.expertMode ? self.frame.width - buttonSize - 8 : 8
                let expertButton = UIButton(frame: CGRect(x: buttonX, y: 0, width: buttonSize, height: buttonSize))
                expertButton.layer.cornerRadius = buttonSize / 2
                expertButton.layer.masksToBounds = true
                expertButton.tag = self.expertUsersViews.count - 1
                expertButton.isHidden = true
                expertButton.alpha = 0
                self.expertButton = expertButton
                self.expertButton?.addTarget(self, action: #selector(self.userSelected(button:)), for: .touchUpInside)
                user.image(completionHandler: { (image) in
                    DispatchQueue.main.async {
                        self.expertButton?.setImage(image, for: .normal)
                        UIView.animate(withDuration: 0.3, animations: {
                            self.expertButton?.alpha = 1
                        })
                    }
                })
                
                self.chatsTableView.addSubview(expertButton)
            }
            
            // Add event in chat
            let userEvent = Event(user: user, belongsToUser: self.expertMode, type: .joinedChat)
            self.addEventToDataSource(userEvent)
            
        case .browsedPage(let browsePageEvent):
            self.addEventToDataSource(browsePageEvent)
            
            if let hostUserId = browsePageEvent.hostUserId, hostUserId != "null" {
                DispatchQueue.main.async {
                    self.hostUserViewTopConstraint.constant = -64
                    self.hostUserView.isHidden = false
                    self.hostUserView.backgroundColor = self.theme.color(.linkBackground)
                    self.hostUserLabel.textColor = self.theme.color(.link)
                    self.hostUserImageView.image = self.hostUserImageView.image?.withRenderingMode(.alwaysTemplate)
                    self.hostUserImageView.tintColor = self.theme.color(.link)
                    
                    let userProfile = self.delegate?.publicProfileUrl(userId: hostUserId, hostId: self.chat!.hostId) ?? hostUserId
                    if let userProfileUrl = URL(string: userProfile) {
                        self.hostUserProfileUrl = userProfileUrl
                        self.hostUserLabel.text = userProfileUrl.relativePath
                    }
                    else {
                        self.hostUserLabel.text = userProfile
                    }
                }
            }
            
        case .writing(let writing, distant: let distant):
            if self.expertInitialization {
                break
            }
            DispatchQueue.main.async {
                self.delegate?.expandedWidgetEvent(type: .userWriting(writing: writing, distant: distant))
                
                let foundWritingUser = self.chatDataSource.writingUsers.firstIndex(of: distant)
                if writing, foundWritingUser == nil {
                    self.chatDataSource.writingUsers.append(distant)
                    UIView.setAnimationsEnabled(false)
                    self.chatsTableView.beginUpdates()
                    let newIndexPath = IndexPath(row: self.chatDataSource.writingUsers.count - 1, section: 1)
                    self.chatsTableView.insertRows(at: [newIndexPath], with: .none)
                    self.chatsTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    self.scrollToTableBottomIfNeeded()
                    
                    if self.shouldShowUser(distant: distant) {
                        let lastEvent = distant ? self.chatDataSource.lastDistantEvent : self.chatDataSource.lastLocalEvent
                        if let newCell = self.chatsTableView.cellForRow(at: newIndexPath) {
                            self.moveExpertButtonToCell(newCell, animated: lastEvent != nil)
                        }
                    }
                }
                else if !writing, let foundWritingUser = foundWritingUser {
                    self.chatDataSource.writingUsers.remove(at: foundWritingUser)
                    let deleteIndexPath = IndexPath(row: foundWritingUser, section: 1)
                    UIView.setAnimationsEnabled(false)
                    self.chatsTableView.beginUpdates()
                    self.chatsTableView.deleteRows(at: [deleteIndexPath], with: .none)
                    self.chatsTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    self.scrollToTableBottomIfNeeded()
                    
                    let lastEvent = distant ? self.chatDataSource.lastDistantEvent : self.chatDataSource.lastLocalEvent
                    if self.shouldShowUser(distant: distant) {
                        if let lastEvent = lastEvent, let indexOfLastEvent = self.chatDataSource.chatEvents.firstIndex(of: lastEvent) {
                            let lastIndexPath = IndexPath(row: indexOfLastEvent, section: 0)
                            if let oldCell = self.chatsTableView.cellForRow(at: lastIndexPath) {
                                self.moveExpertButtonToCell(oldCell, animated: true)
                            }
                            else {
                                self.expertButton?.isHidden = true
                            }
                        }
                    }
                }
            }
            
        case .tagged(tags: let tags):
            DispatchQueue.main.async {
                if tags.count == 0, self.tagsContainerView.subviews.count > 0 {
                    self.tagsContainerView.subviews[0].removeFromSuperview()
                    self.tagsContainerViewHeightConstraint.constant = 0
                    self.bottomView.layoutIfNeeded()
                }
                else {
                    self.tagsView = self.delegate?.tagsView(self.tagsView, chatView: self, tags: tags)
                    
                    if let tagsView = self.tagsView, self.tagsContainerView.subviews.count == 0 {
                        self.tagsContainerViewHeightConstraint.constant = tagsView.frame.height
                        self.bottomView.layoutIfNeeded()
                        self.tagsContainerView.addSubview(tagsView)
                    }
                }
            }
            
        case .expertInitComplete:
            self.expertInitialization = false
            DispatchQueue.main.async {
                self.chatsTableView.reloadData()
                UIView.animate(withDuration: 0.4, animations: {
                    self.activityIndicator.alpha = 0
                }, completion: { (completed) in
                    self.activityIndicator.alpha = 1
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                })
                
                if let lastEvent = self.chatDataSource.lastLocalEvent, let lastEventIndex = self.chatDataSource.chatEvents.firstIndex(of: lastEvent) {
                    let lastIndexPath = IndexPath(row: lastEventIndex, section: 0)
                    if let oldCell = self.chatsTableView.cellForRow(at: lastIndexPath) {
                        self.moveExpertButtonToCell(oldCell, animated: false)
                    }
                }
            }
            
        case .canceledCall:
            DispatchQueue.main.async {
                if !self.expertMode {
                    self.infoLabel.text = "widget.event.timeout".loc()
                    self.detectedLinks.removeAll()
                    self.infoLabel.textColor = Theme.grayText
                    self.infoLabel.isHidden = false
                }
                self.textView.resignFirstResponder()
                self.textView.isEditable = false
                
                if self.expertMode {
                    self.textView.isHidden = true
                    self.textViewPlaceholder.isHidden = true
                    self.sendTextButton.isHidden = true
                    
                    // Handle buttons display
                    self.textView.text = ""
                    self.resizeTextView(force: false)
                    self.quitChatButton.isHidden = false
                    self.textViewSeparator.isHidden = false
                    self.moreActionsButton.isHidden = self.spectator
                }
                
                self.moveBottomViewWithDuration(duration: 0.3)
            }
            
        case .userLeft(isSelf: let isSelf):
            if self.expertMode {
                if !isSelf {
                    // Add event in chat
                    let userEvent = Event(type: .leftChat, belongsToUser: false)
                    self.addEventToDataSource(userEvent)
                }
                
                DispatchQueue.main.async {
                    self.textView.text = ""
                    self.resizeTextView(force: false)
                    self.quitChatButton.isHidden = false
                    self.textViewSeparator.isHidden = false
                    self.textView.isHidden = true
                    self.textViewPlaceholder.isHidden = true
                    self.sendTextButton.isHidden = true
                }
                
                if !self.shareChatEventAdded, self.chat?.shareable ?? false {
                    self.shareChatEventAdded = true
                    let shareEvent = Event(type: .shareChat, belongsToUser: true)
                    self.addEventToDataSource(shareEvent)
                }
            }
            else {
                if !isSelf {
                    // Add event in chat
                    if let user = self.chatDataSource.expertUsers.last {
                        let userEvent = Event(user: user, belongsToUser: false, type: .leftChat)
                        self.addEventToDataSource(userEvent)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.textView.isEditable = false
                self.textView.resignFirstResponder()
                self.moveBottomViewWithDuration(duration: 0.3)
            }
            
        case .calling:
            self.delegate?.expandedWidgetEvent(type: .chatInitialized)
            
            DispatchQueue.main.async {
                self.chatsTableView.isHidden = false
                self.introView.isHidden = true
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.backgroundColor = UIColor.white
                    self.textViewSeparator.isHidden = !self.spectator
                })
                self.textWrapperView.backgroundColor = UIColor.white
                self.textView.layer.borderColor = self.theme.color(.active).cgColor
                self.sendTextButton.tintColor = self.theme.color(.active)
                
                self.infoLabel.text = "widget.event.lookingformember".loc()
                self.detectedLinks.removeAll()
                self.infoLabel.textColor = Theme.grayText
                self.infoLabel.isHidden = false
            }
            
        case .closed:
            DispatchQueue.main.async {
                self.textView.resignFirstResponder()
                self.textView.isEditable = false
                if self.expertMode {
                    self.textView.isHidden = true
                    self.textViewPlaceholder.isHidden = true
                    self.sendTextButton.isHidden = true
                    
                    // Handle buttons display
                    self.textView.text = " "
                    self.resizeTextView(force: false)
                    self.quitChatButton.isHidden = false
                    self.textViewSeparator.isHidden = false
                    self.moreActionsButton.isHidden = self.spectator
                    
                    if !self.shareChatEventAdded, self.chat?.shareable ?? false {
                        self.shareChatEventAdded = true
                        let shareEvent = Event(type: .shareChat, belongsToUser: true)
                        self.addEventToDataSource(shareEvent)
                    }
                }
                self.moveBottomViewWithDuration(duration: 0.3)
            }
            
        case .transferred(event: let transferEvent):
            // Reset stored events
            if transferEvent.belongsToUser {
                self.chatDataSource.lastLocalEvent = nil
            }
            else {
                self.chatDataSource.lastDistantEvent = nil
            }
            self.addEventToDataSource(transferEvent)
            
        case .bannedInterlocutor(event: let banEvent):
            self.addEventToDataSource(banEvent)
            self.chatEvent(type: .closed)

        }
    }
    
    private func addEventToDataSource(_ event: Event) {
        var indexToRefresh: IndexPath?
        if let lastEvent = event.belongsToUser ? self.chatDataSource.lastLocalEvent : self.chatDataSource.lastDistantEvent {
            if let index = self.chatDataSource.chatEvents.firstIndex(of: lastEvent) {
                indexToRefresh = IndexPath(row: index, section: 0)
            }
        }
        if ![EventType.transferredChat, .leftChat, .joinedChat, .bannedInterlocutor, .shareChat].contains(event.type) {
            if event.belongsToUser {
                self.chatDataSource.lastLocalEvent = event
            }
            else {
                self.chatDataSource.lastDistantEvent = event
            }
        }
        
        if !self.expertInitialization {
            // Refresh tableview
            DispatchQueue.main.async {
                if event.type != .browsedPage, let content = event.content {
                    self.delegate?.expandedWidgetEvent(type: .newChatMessage(chatView: self, message: content))
                }
                
                self.chatDataSource.chatEvents.append(event)
                
                UIView.setAnimationsEnabled(false)
                self.chatsTableView.beginUpdates()
                let newIndexPath = IndexPath(row: self.chatsTableView.numberOfRows(inSection: 0), section: 0)
                self.chatsTableView.insertRows(at: [newIndexPath], with: .none)
                
                if let writingUser = self.chatDataSource.writingUsers.firstIndex(of: !event.belongsToUser) {
                    self.chatDataSource.writingUsers.remove(at: writingUser)
                    self.chatsTableView.deleteRows(at: [IndexPath(row: writingUser, section: 1 )], with: .none)
                }
                self.chatsTableView.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                self.scrollToTableBottomIfNeeded()
                
                if self.shouldShowUser(distant: !event.belongsToUser), ![EventType.transferredChat, .leftChat, .joinedChat, .bannedInterlocutor, .shareChat].contains(event.type),
                    let newCell = self.chatsTableView.cellForRow(at: newIndexPath) {
                    self.moveExpertButtonToCell(newCell, animated: indexToRefresh != nil)
                }
            }
        }
        else {
            self.chatDataSource.chatEvents.append(event)
        }
    }
        
    // MARK: - Expert features
    
    public func willToggleChat() {
        DispatchQueue.main.async {
            self.textView.resignFirstResponder()
        }
    }
    
    public func toggleTextViewAndActions(show: Bool, spectator: Bool) {
        DispatchQueue.main.async {
            self.textView.resignFirstResponder()
            self.textView.isEditable = show
            
            self.textView.isHidden = !show
            self.textViewPlaceholder.isHidden = !show
            self.sendTextButton.isHidden = !show
            
            // Handle buttons display
            if !show {
                self.textView.text = " "
            }
            self.quitChatButton.isHidden = show
            self.textViewSeparator.isHidden = show
            self.moreActionsButton.isHidden = !show
            
            self.spectator = spectator
            self.chat?.spectator = spectator
        }
    }
        
    public func snapshotView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.chatsTableView.contentSize, false, 0)
        let savedContentOffset = self.chatsTableView.contentOffset
        let savedFrame = self.chatsTableView.frame
        
        self.chatsTableView.contentOffset = CGPoint.zero
        self.chatsTableView.frame = CGRect(x: 0, y: 0, width: self.chatsTableView.contentSize.width, height: self.chatsTableView.contentSize.height)
        
        self.chatsTableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        self.chatsTableView.contentOffset = savedContentOffset
        self.chatsTableView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
        
    // MARK: - Utility methods
    
    private func shouldShowUser(distant: Bool) -> Bool {
        return (distant && !self.expertMode) || (!distant && self.expertMode)
    }
    
    private func moveExpertButtonToCell(_ cell : UITableViewCell, animated: Bool) {
        guard let expertButton = self.expertButton else {
            return
        }
        
        expertButton.isHidden = false
        let cellHeight = cell is ChatUserCell ? 49 : cell.frame.height
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            expertButton.frame = CGRect(x: expertButton.frame.origin.x, y: cell.frame.origin.y + cellHeight - expertButton.frame.height - 3, width: expertButton.frame.width, height: expertButton.frame.height)
        }
    }
    
    private func scrollToTableBottomIfNeeded() {
        let totalScroll = self.chatsTableView.contentOffset.y + self.chatsTableView.frame.height
        let contentHeight = self.chatsTableView.contentSize.height
        if contentHeight < totalScroll + 50 {
            self.scrollToTableBottom()
        }
    }
    
    private func scrollToTableBottom() {
        let numberOfChats = self.chatsTableView.numberOfRows(inSection: 0)
        let numberOfWritingUsers = self.chatsTableView.numberOfRows(inSection: 1)
        if numberOfChats > 0 {
            var scrollIndex = IndexPath(row: numberOfChats - 1, section: 0)
            if numberOfWritingUsers > 0 {
                scrollIndex = IndexPath(row: numberOfWritingUsers - 1, section: 1)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.chatsTableView.scrollToRow(at: scrollIndex, at: .bottom, animated: false)
            })
        }
    }
    
    public func refreshTheme(_ theme: Theme) {
        self.theme = theme
        self.chatDataSource.theme = theme
        self.chatsTableView.reloadData()
        
        self.backgroundColor = theme.color(.background)
        self.sendTextButton.tintColor = theme.color(.subtitle)
        self.moreActionsButton.tintColor = theme.color(.subtitle)
        self.textView.layer.borderColor = theme.color(.subtitle).cgColor
        self.textView.textColor = theme.color(.subtitle)
        self.quitChatButton.tintColor = theme.color(.subtitle)
        self.activityIndicator.color = theme.color(.subtitle)
    }
    
    private func userSelected(user: User, imageView: UIImageView, fromFrame: CGRect, view: UIView) {
        self.textView.resignFirstResponder()
        
        // Try expert mode, fallback to classic mode
        if !(self.delegate?.showUser(user: user, hostId: chat!.hostId, imageView: imageView) ?? false) {
            if let userIndex = self.chatDataSource.expertUsers.firstIndex(of: user) {
                let infoView = self.expertUsersViews[userIndex]
                infoView.show(fromFrame: infoView.convert(fromFrame, from: view))
            }
        }
    }
        
    // MARK: - UICollectionViewDelegate and UICollectionViewDataSource methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        // If completion view is not ready yet, don't display its cell
        if self.thanksCellIndexPath == nil, self.scoreCellIndexPath == nil,self.firstAbuseCellIndexPath == nil {
            return numberOfItems
        }
        if self.chat?.status != .opened {
            numberOfItems = 3 // abuse cells
            if self.chat?.communityInterlocutors.count ?? 0 > 0 {
                numberOfItems += 1
            }
            if self.chat?.supportInterlocutors.count ?? 0 > 0 {
                numberOfItems += 1
            }
        }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let firstAbuseCellIndexPath = self.firstAbuseCellIndexPath ?? -1
        switch indexPath.item {
        case self.thanksCellIndexPath ?? -1:
            return self.thanksCell(indexPath: indexPath)
        case self.scoreCellIndexPath ?? -1:
            return self.scoreCell(indexPath: indexPath)
        case firstAbuseCellIndexPath:
            return self.abuseDisclaimerCellForIndexPath(indexPath: indexPath)
        case firstAbuseCellIndexPath + 1:
            return self.abuseCellForIndexPath(indexPath: indexPath)
        case firstAbuseCellIndexPath + 2:
            return self.abuseCompleteCellForIndexPath(indexPath: indexPath)
        default:
            break
        }
        return UICollectionViewCell()
    }
    
    private func thanksCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.completionCollectionView.dequeueReusableCell(withReuseIdentifier: "thanksCell", for: indexPath) as! ThanksCell
        cell.delegate = self
        cell.refresh(cellWidth: self.frame.width, interlocutors: self.chat!.communityInterlocutors)
        return cell
        
    }
    
    private func scoreCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.completionCollectionView.dequeueReusableCell(withReuseIdentifier: "scoreCell", for: indexPath) as! ScoreCell
        cell.delegate = self
        cell.refresh(cellWidth: self.frame.width, thanks: self.chat!.communityInterlocutors.count > 0, interlocutors: self.chat!.supportInterlocutors)
        return cell
    }
    
    private func abuseDisclaimerCellForIndexPath(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.completionCollectionView.dequeueReusableCell(withReuseIdentifier: "abuseDisclaimerCell", for: indexPath) as! AbuseDisclaimerCell
        cell.delegate = self
        cell.refresh(cellWidth: self.frame.width)
        return cell
    }
    
    private func abuseCellForIndexPath(indexPath: IndexPath) -> UICollectionViewCell {
        if self.abuseCell == nil {
            let cell = self.completionCollectionView.dequeueReusableCell(withReuseIdentifier: "abuseCell", for: indexPath) as! AbuseCell
            cell.delegate = self
            self.abuseCell = cell
        }
        self.abuseCell?.refresh()
        return self.abuseCell!
    }
    
    private func abuseCompleteCellForIndexPath(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.completionCollectionView.dequeueReusableCell(withReuseIdentifier: "abuseCompleteCell", for: indexPath) as! AbuseCompleteCell
        cell.delegate = self
        cell.refresh(cellWidth: self.frame.width)
        return cell
    }
        
    // MARK: - Orientation change handlers
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let shouldRefresh = self.previousWindowWidth != self.window?.frame.width
        self.previousWindowWidth = self.window?.frame.width
        
        if shouldRefresh {
            self.windowSizeDidChange()
        }
    }
    
    private func windowSizeDidChange() {
        if !self.expertMode {
            Utility.delay(UIApplication.shared.statusBarOrientationAnimationDuration, closure: {
                if #available(iOS 11.0, *) {
                    var topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
                    if topInset == 0 {
                        topInset = Constants.Dimensions.statusBarHeight
                    }
                    self.topViewHeightConstraint.constant = self.frame.origin.y == 0 ? 44 + topInset : topInset
                } else {
                    self.topViewHeightConstraint.constant = self.frame.origin.y == 0 ? 44 + UIApplication.shared.statusBarFrame.height : 44
                }
            })
        }
        
        self.layoutIfNeeded()
        
        // Redraw CollectionView (not working fine at the moment)
        (self.completionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: self.frame.width, height: self.frame.height)
        self.completionCollectionView.collectionViewLayout.invalidateLayout()
        
        // Redraw tableview
        self.chatDataSource.tableWidth = self.frame.width
        self.chatsTableView.reloadData()
        
        // Move user button
        if let lastEvent = self.expertMode ? self.chatDataSource.lastLocalEvent : self.chatDataSource.lastDistantEvent,
            let lastEventIndex = self.chatDataSource.chatEvents.firstIndex(of: lastEvent) {
            let lastIndexPath = IndexPath(row: lastEventIndex, section: 0)
            if let oldCell = chatsTableView.cellForRow(at: lastIndexPath) {
                self.moveExpertButtonToCell(oldCell, animated: true)
            }
        }
    }
        
    // MARK: - ScoreCellDelegate methods
    
    func didScore(note: Int) {
        self.delegate?.expandedWidgetEvent(type: .scoredInterlocutor(note: note))
        
        if let interlocutorsIds = self.chat?.supportInterlocutors.map({ $0.id }).joined(separator: ",") {
            self.chat?.scoredInterlocutors(interlocutorIds: interlocutorsIds, note: note)
        }
        self.closeWidgetAction()
    }
    
    func userSelected(user: User, imageView: UIImageView, fromFrame: CGRect) {
        self.userSelected(user: user, imageView: imageView, fromFrame: fromFrame, view: self.completionView)
    }
        
    // MARK: - ThanksCellDelegate methods
    
    func didThanks() {
        self.delegate?.expandedWidgetEvent(type: .thankedInterlocutor)
        
        if let interlocutorsIds = self.chat?.communityInterlocutors.map({ $0.id }).joined(separator: ",") {
            self.chat?.thankedInterlocutors(interlocutorIds: interlocutorsIds)
        }
        if self.chat?.supportInterlocutors.count ?? 0 > 0 {
            self.delegate?.expandedWidgetEvent(type: .scoringInterlocutor)
            self.lastScrolledIndexPath = 1
            self.scrollToItem()
        }
        else {
            self.closeWidgetAction()
        }
    }
    
    func didNotThanks() {
        self.closeWidgetAction()
    }
    
    func shouldReportAbuse() {
        self.indexPathBeforeAbuse = completionCollectionView.indexPathsForVisibleItems[0].item
        self.lastScrolledIndexPath = self.firstAbuseCellIndexPath
        self.scrollToItem()
        UIApplication.hideKeyboard()
    }
        
    // MARK: - AbuseDisclaimerCellDelegate methods
    
    func cancelAbuse() {
        self.lastScrolledIndexPath = self.indexPathBeforeAbuse
        self.indexPathBeforeAbuse = nil
        self.scrollToItem()
    }
    
    func confirmAbuseDisclaimer() {
        self.lastScrolledIndexPath = (self.firstAbuseCellIndexPath ?? 0) + 1
        self.scrollToItem()
    }
        
    // MARK: - AbuseCellDelegate methods
    
    func confirmAbuse(email: String, comment: String) {
        self.chat?.notifyAbuse(email: email, comment: comment, completion: { (success, errorType) in
            if success {
                self.lastScrolledIndexPath = (self.firstAbuseCellIndexPath ?? 0) + 2
                self.scrollToItem()
            }
            else {
                self.abuseCell?.displayError(type: errorType)
            }
        })
    }
    
    func willBeginEditingComment() {
        self.completionCommentView.isHidden = false
        self.completionTextView.becomeFirstResponder()
    }
        
    // MARK: - AbuseCompleteCellDelegate methods
    
    func abuseComplete() {
        self.closeWidgetAction()
    }

}

