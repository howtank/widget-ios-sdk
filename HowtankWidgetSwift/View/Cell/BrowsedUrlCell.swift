//
//  BrowsedUrlCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 06/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class BrowsedUrlCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
        
    // MARK: - Refresh methods
    
    func refresh(event: Event, theme: Theme) {
        if var urlString = event.url {
            if let url = URL(string: urlString), let scheme = url.scheme, let host = url.host {
                let schemeAndHost = "\(scheme)://\(host)"
                urlString = urlString.replacingOccurrences(of: schemeAndHost, with: "")
            }
            
            self.urlLabel.textColor = theme.color(.link)
            self.bubbleView.backgroundColor = theme.color(.linkBackground)
            
            let attributedString = NSAttributedString(string: urlString, attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
            self.urlLabel.attributedText = attributedString
        }
    }

}
