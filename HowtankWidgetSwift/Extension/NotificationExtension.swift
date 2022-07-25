//
//  NotificationExtension.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

extension Notification {
    
    public func keyboardHeight(forView view: UIView) -> CGFloat {
        let info = self.userInfo!
        let keyboardScreenEndFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        var viewBounds: CGRect
        if #available(iOS 11.0, *) {
            viewBounds = view.safeAreaLayoutGuide.layoutFrame
        } else {
            viewBounds = view.bounds
        }
        
        // Special case for iPad
        if UIScreen.main.bounds.width >= 530 {
            viewBounds = CGRect(x: viewBounds.origin.x, y: -max(0, view.frame.origin.y - 20), width: viewBounds.width, height: viewBounds.height)
        }
        
        return viewBounds.intersection(keyboardViewEndrame).height
    }
    
}

extension UIApplication {
    
    class func hideKeyboard() {
        UIApplication.shared.delegate?.window??.endEditing(true)
    }
    
}
