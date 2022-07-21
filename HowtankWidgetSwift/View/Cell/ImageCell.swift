//
//  ImageCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 06/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol ImageCellDelegate {
    func willZoomImage(imageView: UIImageView)
}

class ImageCell: UITableViewCell {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var imageOpacityLayerView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
        
    // MARK: - Properties
    
    var delegate: ImageCellDelegate?
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.chatImageView.layer.cornerRadius = 5
        self.chatImageView.layer.masksToBounds = true
        self.imageButton.layer.cornerRadius = 5
        self.imageOpacityLayerView.layer.cornerRadius = 5
        self.imageOpacityLayerView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.chatImageView.image = nil
    }
    

    // MARK: - Refresh methods
    
    func refresh(event: Event) {
        if let image = event.image {
            let imageSize = self.imageSize(image: image)
            self.chatImageView.image = image
            self.imageWidthConstraint.constant = imageSize.width
            self.imageHeightConstraint.constant = imageSize.height
            self.trailingConstraint.constant = event.user != nil ? 45 : 10
        }
    }
    
    func cellHeight(event: Event) -> CGFloat {
        if let image = event.image {
            return self.imageSize(image: image).height + 10
        }
        return 0
    }
        
    // MARK: - IBActions
    
    @IBAction func touchedDown(_ sender: Any) {
        self.imageOpacityLayerView.alpha = 0.2
    }
    
    @IBAction func touchedUpOutside(_ sender: Any) {
        self.imageOpacityLayerView.alpha = 0
    }
    
    @IBAction func touchedImage(_ sender: Any) {
        self.imageOpacityLayerView.alpha = 0
        self.delegate?.willZoomImage(imageView: self.chatImageView)
    }
        
    // MARK: - Utility methods
    
    private func imageSize(image: UIImage) -> CGSize {
        let screenScale = UIScreen.main.scale
        var imageSize = CGSize(width: image.size.width / screenScale, height: image.size.height / screenScale)
        if imageSize.width > Constants.Dimensions.maxImageWidth {
            imageSize = CGSize(width: Constants.Dimensions.maxImageWidth, height: Constants.Dimensions.maxImageWidth * imageSize.height / imageSize.width)
        }
        if imageSize.height > Constants.Dimensions.maxImageHeight {
            imageSize = CGSize(width: Constants.Dimensions.maxImageHeight * imageSize.width / imageSize.height, height: Constants.Dimensions.maxImageHeight)
        }
        return imageSize
    }
    
}
 
