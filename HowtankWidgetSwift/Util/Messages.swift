//
//  Messages.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

public class Messages {

    // MARK: - Singleton
    
    public static let shared = Messages()
        
    // MARK: - Properties
    
    public private(set) var messages = [String: String]()
        
    // MARK: - Public methods
    
    public func message(key: String) -> String? {
        return messages[key]
    }
    
    public func fill(messages: [String: String]) {
        self.messages = messages
    }
    
}

extension String {
    func loc (`default`: String? = nil) -> String {
        let localizedString = Messages.shared.message(key: self) ?? `default` ?? self
        
        return localizedString.replacingOccurrences(of: "<br/>", with: " ").replacingOccurrences(of: "<br />", with: " ")
    }
}

