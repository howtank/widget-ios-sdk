//
//  Utility.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 31/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import Foundation

func cDebug(verbose: Bool = true, _ message: String, args: CVarArg...) {
    let string = NSString(format: message, arguments: getVaList(args))
    if HowtankWidget.shared.verboseMode || !verbose {
        NSLog("[Howtank widget] \(string)")
    }
}

class Utility: NSObject {
    class func delay(_ delay:Double, closure: @escaping () -> Void) {
        let waitDelay = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: waitDelay, execute: closure)
    }
    
    /// Get top level view controller
    public class func topLevelViewController() -> UIViewController?
    {
        var viewController: UIViewController?
        if let window = UIApplication.shared.delegate!.window
        {
            if var presentingViewController = window?.rootViewController
            {
                while let modalVC = presentingViewController.presentedViewController
                {
                    presentingViewController = modalVC
                }
                viewController = presentingViewController
            }
        }
        return viewController
    }
}
