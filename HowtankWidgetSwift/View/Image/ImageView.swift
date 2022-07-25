//
//  ImageView.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 08/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

class ImageView: UIView {

    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
        
    // MARK: - Public methods
    
    func display(image: UIImage?, fromFrame: CGRect) {
        
    }
    
    
    /*
     
     
     @implementation HTImageView {
     __weak IBOutlet UIImageView *_imageView;
     
     CGRect _originFrame;
     }
     
     - (void)awakeFromNib {
     [super awakeFromNib];
     
     [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)]];
     }
     
     - (void)displayImage:(UIImage*)image fromFrame:(CGRect)frame {
     [self layoutIfNeeded];
     _originFrame = frame;
     self.backgroundColor = [UIColor clearColor];
     _imageView.image = image;
     _imageView.frame = _originFrame;
     self.hidden = NO;
     
     CGFloat imageHeight = self.frame.size.width * (image.size.height / image.size.width);
     CGRect finalFrame = CGRectMake(0, (self.frame.size.height - imageHeight) / 2, self.frame.size.width, imageHeight);
     [UIView animateWithDuration:0.3 animations:^{
     self.backgroundColor = [UIColor blackColor];
     }];
     [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
     _imageView.frame = finalFrame;
     } completion:nil];
     }
     
     #pragma mark - Gesture recognizer
     
     - (IBAction)closeView:(id)sender {
     [UIView animateWithDuration:0.3 animations:^{
     self.backgroundColor = [UIColor clearColor];
     }];
     [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
     _imageView.frame = _originFrame;
     } completion:^(BOOL finished) {
     self.hidden = YES;
     }];
     }
     
     @end

    */

}
