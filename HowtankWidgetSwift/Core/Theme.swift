//
//  Theme.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public class ColorItem: NSObject {
    let type: Theme.ColorType
    let color: UIColor
    
    @objc public init(type: Theme.ColorType, color: UIColor) {
        self.type = type
        self.color = color
    }
}

public class Theme : NSObject {
 
    @objc public enum ColorType: Int {
        case theme
        case active
        
        case themeText
        case activeText
        
        case bubbleActive
        case bubbleActiveText
        case bubbleInactive
        case bubbleInactiveText
        
        case userChat
        case distantChat
        case userChatText
        case distantChatText
        case userWritingView
        case distantWritingView
        
        case introText
        case introBackground
        case disclaimerText
        
        case link
        case linkBackground
        
        // Expert
        case background
        case title
        case subtitle
        case thumb
        case inactive
        case tabs
        case header
        
        var keyValue: String {
            switch self {
            case .theme: return "theme_color"
            case .active: return "active_color"
            case .themeText: return "theme_text_color"
            case .activeText: return "active_text_color"
            case .bubbleActive: return "bubble_active_color"
            case .bubbleActiveText: return "bubble_active_text_color"
            case .bubbleInactive: return "bubble_inactive_color"
            case .bubbleInactiveText: return "bubble_inactive_text_color"
            case .userChat: return "user_chat_color"
            case .distantChat: return "distant_chat_color"
            case .userChatText: return "user_chat_text_color"
            case .distantChatText: return "distant_chat_text_color"
            case .userWritingView: return "user_writing_view_color"
            case .distantWritingView: return "distant_writing_view_color"
            case .introText: return "intro_text_color"
            case .introBackground: return "intro_background_color"
            case .disclaimerText: return "disclaimer_text_color"
            case .link: return "link_color"
            case .linkBackground: return "link_background_color"
            case .background: return "background_color"
            case .title: return "title_color"
            case .subtitle: return "subtitle_color"
            case .thumb: return "thumb_color"
            case .inactive: return "inactive_color"
            case .tabs: return "tabs_color"
            case .header: return "header_color"
            }
        }
        
        
        var defaultColor: UIColor {
            switch self {
            case .theme:
                return UIColor(red: 60/255, green: 58/255, blue: 58/255, alpha: 1)
            case .active:
                return UIColor(red: 36/255, green: 159/255, blue: 255/255, alpha: 1)
                
            case .themeText:
                return Theme.shared.color(.theme).brightnessValue() > 0.5 ? UIColor.black : UIColor.white
            case .activeText:
                return Theme.shared.color(.active).brightnessValue() > 0.5 ? UIColor.black : UIColor.white
                
            case .bubbleActive:
                return Theme.shared.color(.active)
            case .bubbleActiveText:
                return Theme.shared.color(.activeText)
            case .bubbleInactive:
                return Theme.shared.color(.theme)
            case .bubbleInactiveText:
                return Theme.shared.color(.themeText)
                
            case .userChat:
                return UIColor(red: 8/255, green: 148/255, blue: 244/255, alpha: 1)
            case .distantChat:
                return UIColor(red: 245/255, green: 242/255, blue: 240/255, alpha: 1)
            case .userChatText:
                return Theme.shared.color(.userChat).brightnessValue() > 0.5 ? UIColor.black : UIColor.white
            case .distantChatText:
                return Theme.shared.color(.distantChat).brightnessValue() > 0.5 ? UIColor.black : UIColor.white
            case .userWritingView:
                return Theme.shared.color(.userChat).brightnessValue() > 0.5 ? UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1) : UIColor.white
            case .distantWritingView:
                return Theme.shared.color(.distantChat).brightnessValue() > 0.5 ? UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1) : UIColor.white
                
            case .introText:
                return Theme.shared.color(.themeText)
            case .introBackground:
                return Theme.shared.color(.theme)
            case .disclaimerText:
                return UIColor(red: 150/255, green: 149/255, blue: 149/255, alpha: 1)
                
            case .link:
                return UIColor.black
            case .linkBackground:
                return UIColor(red: 227/255, green: 242/255, blue: 1, alpha: 1)
                
                
            case .background:
                return UIColor.white
            case .title:
                return Theme.grayText
            case .subtitle:
                return Theme.grayText
            case .thumb:
                return UIColor(hue: 221/360, saturation: 0.23, brightness: 0.27, alpha: 1)
            case .inactive:
                return UIColor(hue: 221/360, saturation: 0.23, brightness: 0.36, alpha: 1)
            case .tabs:
                return UIColor(red: 54/255, green: 59/255, blue: 71/255, alpha: 1)
            case .header:
                return UIColor(red: 51/255, green: 54/255, blue: 66/255, alpha: 1)
            }
        }
    }
    
    // MARK: - Singleton
    
    static let shared = Theme()
        
    // MARK: - Properties
    
    private var theme = [String: String]()
    private var cachedColors = [ColorType: UIColor]()
    
    private(set) var activeChatImage: UIImage?
    private(set) var inactiveChatImage: UIImage?
    
    private var customFontName: String?
    private var customBoldFontName: String?
    
    private var customPosition: String?
    
    public internal(set) var isLight = false
        
    // MARK: - Constructor
    
    private override init() {
        super.init()
        self.activeChatImage = UIImage(named: "chat_image", in: Bundle.howtankBundle(owner: self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.inactiveChatImage = UIImage(named: "chat_image", in: Bundle.howtankBundle(owner: self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    public init(colors: [ColorType: UIColor]) {
        self.cachedColors = colors
    }
    
    @objc public init(options: [ColorItem]) {
        self.cachedColors.removeAll()
        for option in options {
            self.cachedColors[option.type] = option.color
        }
    }
        
    // MARK: - Fill theme
    
    func fill(theme: [String: String]) {
        self.theme = theme
    }
    
    func fill(theme: Theme) {
        self.cachedColors.removeAll()
        self.cachedColors = theme.cachedColors
    }
        
    // MARK: - Fonts
    
    func setCustomFont(fontName: String, boldFontName: String? = nil) {
        self.customFontName = fontName
        self.customBoldFontName = boldFontName ?? fontName
    }
    
    func fontOfSize(_ fontSize: CGFloat) -> UIFont {
        if let customFontName = self.customFontName, let font = UIFont(name: customFontName, size: fontSize) {
            return font
        }
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    func boldFontOfSize(_ fontSize: CGFloat) -> UIFont {
        if let customFontName = self.customBoldFontName, let font = UIFont(name: customFontName, size: fontSize) {
            return font
        }
        return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
        
    // MARK: - Custom images
    
    func setCustomImages(inactiveImage: UIImage? = nil, activeImage: UIImage? = nil) {
        if let inactiveImage = inactiveImage {
            self.inactiveChatImage = inactiveImage
        }
        if let activeImage = activeImage {
            self.activeChatImage = activeImage
        }
    }
        
    // MARK: - Theme colors
    
    public func color(_ type: ColorType) -> UIColor {
        // Search for cached color
        if let cachedColor = self.cachedColors[type] {
            return cachedColor
        }
        
        // Get color from theme and cache it
        if let color = UIColor(hex: self.theme[type.keyValue]) {
            self.cachedColors[type] = color
            return color
        }
        
        // If no color was found, save default color in cache and return it
        self.cachedColors[type] = type.defaultColor
        return type.defaultColor
    }
    
    class var grayText: UIColor {
        return UIColor(red: 150/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
    }
    
    class var grayBorder: UIColor {
        return UIColor(red: 60/255, green: 58/255, blue: 58/255, alpha: 1)
    }
        
    // MARK: - Theme positions
    
    func position() -> (top: String, right: String, bottom: String, left: String) {
        if let position = self.customPosition ?? self.theme["position"] {
            let components = position.components(separatedBy: " ")
            return (top: components[0], right: components[1], bottom: components[2], left: components[3])
        }
        return (top: "0", right: "0", bottom: "-", left: "-")
    }
    
    func setCustomPositionAndReturnIfChanged(_ position: String?) -> Bool {
        let different = self.customPosition != position
        self.customPosition = position
        return different
    }
    
    func minimumMargins() -> (top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        if let margins = self.customPosition ?? self.theme["minimum_margin"] {
            let components = margins.components(separatedBy: " ")
            return (top: components[0].toCGFloat() ?? 0, right: components[1].toCGFloat() ?? 0, bottom: components[2].toCGFloat() ?? 0, left: components[3].toCGFloat() ?? 0)
        }
        return (top: 0, right: 0, bottom: 0, left: 0)
    }
    
}


