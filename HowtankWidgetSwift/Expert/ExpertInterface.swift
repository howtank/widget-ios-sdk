//
//  ExpertInterface.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 13/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//


extension Theme {
    
    /// Expert themes
    public static var defaultExpert: Theme {
        let distantChatTextColor = UIColor(hue: 223/360, saturation: 0, brightness: 1, alpha: 1)
        let userChatTextColor = UIColor(hue: 221/360, saturation: 0.23, brightness: 0.27, alpha: 1)
        let theme = Theme(colors: [
            .background: UIColor(hue: 221/360, saturation: 0.23, brightness: 0.27, alpha: 1),
            .active: UIColor.white,
            .distantChat: UIColor(hue: 223/360, saturation: 0.23, brightness: 0.47, alpha: 1),
            .userChat: UIColor(hue: 223/360, saturation: 0, brightness: 1, alpha: 1),
            .distantChatText: distantChatTextColor,
            .title: UIColor(hue: 223/360, saturation: 0, brightness: 1, alpha: 1),
            .userChatText: userChatTextColor,
            .distantWritingView: distantChatTextColor,
            .userWritingView: userChatTextColor,
            .link: UIColor(hue: 221/360, saturation: 0, brightness: 1, alpha: 1),
            .linkBackground: UIColor(hue: 224/360, saturation: 0.27, brightness: 0.34, alpha: 1),
            .subtitle: UIColor(hue: 223/360, saturation: 0.17, brightness: 0.85, alpha: 1)
            ])
        
        return theme
    }
    
    public class func light(hue: CGFloat) -> Theme {
        let distantChatTextColor = UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1)
        let userChatTextColor = UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1)
        let theme = Theme(colors: [
            .thumb: UIColor(hue: hue, saturation: 0.20, brightness: 0.96, alpha: 1),
            .background: UIColor(hue: hue, saturation: 0.05, brightness: 0.96, alpha: 1),
            .inactive: UIColor(hue: hue, saturation: 0.06, brightness: 0.85, alpha: 1),
            .active: UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1),
            .userChat: UIColor(hue: 120/360, saturation: 0, brightness: 0.98, alpha: 1),
            .distantChat: UIColor(hue: hue, saturation: 0.16, brightness: 0.87, alpha: 1),
            .tabs: UIColor(hue: hue, saturation: 0.10, brightness: 0.95, alpha: 1),
            .header: UIColor(hue: hue, saturation: 0.15, brightness: 0.89, alpha: 1),
            .userChatText: userChatTextColor,
            .distantChatText: distantChatTextColor,
            .title: UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1),
            .distantWritingView: distantChatTextColor,
            .userWritingView: userChatTextColor,
            .link: UIColor(hue: hue, saturation: 0, brightness: 0.34, alpha: 1),
            .linkBackground: UIColor(hue: hue, saturation: 0.09, brightness: 0.85, alpha: 1),
            .subtitle: UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1)
            ])
        theme.isLight = true
        return theme
    }
    
    public class func dark(hue: CGFloat) -> Theme {
        let distantChatTextColor = UIColor(hue: hue, saturation: 0.24, brightness: 0.37, alpha: 1)
        let userChatTextColor = UIColor(hue: hue, saturation: 0.24, brightness: 0.37, alpha: 1)
        let theme = Theme(colors: [
            .thumb: UIColor(hue: hue, saturation: 0.23, brightness: 0.73, alpha: 1),
            .background: UIColor(hue: hue, saturation: 0.21, brightness: 0.44, alpha: 1),
            .inactive: UIColor(hue: hue, saturation: 0.23, brightness: 0.38, alpha: 1),
            .active: UIColor.white,
            .userChat: UIColor(hue: 120/360, saturation: 0, brightness: 0.98, alpha: 1),
            .distantChat: UIColor(hue: hue, saturation: 0.13, brightness: 0.96, alpha: 1),
            .tabs: UIColor(hue: hue, saturation: 0.20, brightness: 0.41, alpha: 1),
            .header: UIColor(hue: hue, saturation: 0.23, brightness: 0.38, alpha: 1),
            .userChatText: userChatTextColor,
            .distantChatText: distantChatTextColor,
            .title: UIColor.white,
            .distantWritingView: distantChatTextColor,
            .userWritingView: userChatTextColor,
            .link: UIColor.white,
            .linkBackground: UIColor(hue: hue, saturation: 0.23, brightness: 0.38, alpha: 1),
            .subtitle: UIColor.white
            ])
        return theme
    }
    
    public static var sahara: Theme {
        let hue: CGFloat = 40/360
        let distantChatTextColor = UIColor(hue: 0, saturation: 0, brightness: 0.20, alpha: 1)
        let userChatTextColor = UIColor(hue: 0, saturation: 0, brightness: 0.20, alpha: 1)
        let theme = Theme(colors: [
            .thumb: UIColor(hue: hue, saturation: 0.03, brightness: 0.90, alpha: 1),
            .background: UIColor(hue: hue, saturation: 0.01, brightness: 0.95, alpha: 1),
            .inactive: UIColor(hue: hue, saturation: 0.02, brightness: 0.85, alpha: 1),
            .active: UIColor(hue: hue, saturation: 0, brightness: 0.20, alpha: 1),
            .userChat: UIColor.white,
            .distantChat: UIColor(hue: hue, saturation: 0.09, brightness: 0.87, alpha: 1),
            .tabs: UIColor(hue: hue, saturation: 0.03, brightness: 0.93, alpha: 1),
            .header: UIColor(hue: hue, saturation: 0.07, brightness: 0.89, alpha: 1),
            .userChatText: userChatTextColor,
            .distantChatText: distantChatTextColor,
            .title: UIColor(hue: 0, saturation: 0, brightness: 0.20, alpha: 1),
            .distantWritingView: distantChatTextColor,
            .userWritingView: userChatTextColor,
            .link: UIColor(hue: hue, saturation: 0, brightness: 0.34, alpha: 1),
            .linkBackground: UIColor(hue: hue, saturation: 0.02, brightness: 0.85, alpha: 1),
            .subtitle: UIColor(hue: 0, saturation: 0, brightness: 0.20, alpha: 1)
            ])
        theme.isLight = true
        return theme
    }
    
}

