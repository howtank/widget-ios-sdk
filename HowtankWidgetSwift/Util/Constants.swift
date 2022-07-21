//
//  Constants.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

struct Constants {
    
    static let widgetVersion = "2.1.1"
    
    struct Api
    {
        struct Production {
            private static let domain = "www.howtank.com"
            static let secureHost = "https://" + domain
            static let secureCdnHost = "https://cdn.howtank.com"
        }
        struct Sandbox {
            private static let domain = "c1.howtank.com"
            static let secureHost = "https://" + domain
            static let secureCdnHost = "https://c1.howtank.com"
        }
        static let version = 1
    }
    
    struct Keys {
        static let deletedDate = "com.howtank.widget.deleted.date"
        static let uuid = "com.howtank.widget.uuid"
        static let hostSessionId = "com.howtank.widget.hostSessionId"
    }
    
    struct Delay {
        static let errorCallback = 1.0
        static let nextCall = 0.05
        static let writingMessageLock = 4.0
        static let distantWritingMessageLock = 5.0
    }
    
    struct Dimensions {
        static let statusBarHeight: CGFloat = 20
        static let maxImageWidth: CGFloat = 200
        static let maxImageHeight: CGFloat = 150
    }
}
