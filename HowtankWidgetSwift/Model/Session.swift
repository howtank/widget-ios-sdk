//
//  Session.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public class Session {    
    // MARK: - Properties
    
    public private(set) var secureApiHost: String?
    public private(set) var secureCdnHost: String?
        
    // MARK: - Singleton
    
    /// Session instance
    public static let shared = Session()
        
    // MARK: - Configure methods
    
    public func configure(secureApiHost: String, secureCdnHost: String) {
        self.secureApiHost = secureApiHost
        self.secureCdnHost = secureCdnHost
    }
    
}
