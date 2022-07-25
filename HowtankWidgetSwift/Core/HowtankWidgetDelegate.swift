//
//  HowtankWidgetDelegate.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 30/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

@objc public protocol HowtankWidgetDelegate {

    /// Method called whenever there is a new widget event
    func widgetEvent(event: WidgetEventType, paramaters: [String: Any]?)
    /// Optional - Implement this method if you want to overrid the close message. Return true if implemented and closeCallback when widget should close
    func widgetShouldClose(message: String, closeCallback: @escaping ()->Void) -> Bool
    
}

public extension HowtankWidgetDelegate {
    func widgetShouldClose(message: String, closeCallback: ()->Void) -> Bool { return false }
}
