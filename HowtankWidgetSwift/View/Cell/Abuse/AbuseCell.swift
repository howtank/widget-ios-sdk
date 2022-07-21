//
//  AbuseCell.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

protocol AbuseCellDelegate {
    func cancelAbuse()
    func confirmAbuse(email: String, comment: String)
    func willBeginEditingComment()
}

class AbuseCell: UICollectionViewCell, UITextViewDelegate, UITextFieldDelegate {    
    // MARK: - IBOutlets
    
    @IBOutlet weak var abuseTitleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailPlaceholderLabel: UILabel!
    
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentPlaceholderLabel: UILabel!
    @IBOutlet weak var commentCounterLabel: UILabel!
    
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
        
    // MARK: - Properties
    
    var delegate: AbuseCellDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = Theme.shared
        
        self.validationButton.layer.cornerRadius = 5
        self.validationButton.backgroundColor = theme.color(.active)
        
        self.emailContainerView.layer.borderColor = Theme.grayBorder.cgColor
        self.emailContainerView.layer.borderWidth = 0.5
        self.commentContainerView.layer.borderColor = Theme.grayBorder.cgColor
        
        self.commentContainerView.layer.borderWidth = 0.5
        
        self.abuseTitleLabel.text = "widget.abuse.heading".loc()
        self.emailPlaceholderLabel.text = "widget.placeholder.email".loc()
        self.emailPlaceholderLabel.textColor = Theme.grayText
        self.commentPlaceholderLabel.text = "widget.placeholder.comment".loc()
        self.commentPlaceholderLabel.textColor = Theme.grayText
        self.commentCounterLabel.textColor = Theme.grayText
        
        self.cancelButton.setTitle("widget.button.cancel".loc(), for: .normal)
        self.cancelButton.setTitleColor(Theme.grayText, for: .normal)
        self.validationButton.setTitle("widget.button.send".loc(), for: .normal)
        
        self.abuseTitleLabel.font = theme.boldFontOfSize(self.abuseTitleLabel.font.pointSize)
        self.emailPlaceholderLabel.font = theme.fontOfSize(self.emailPlaceholderLabel.font.pointSize)
        self.commentPlaceholderLabel.font = theme.fontOfSize(self.commentPlaceholderLabel.font.pointSize)
        self.cancelButton.titleLabel?.font = theme.fontOfSize(self.cancelButton.titleLabel!.font.pointSize)
        self.validationButton.titleLabel?.font = theme.fontOfSize(self.validationButton.titleLabel!.font.pointSize)
        
        // Add observers to handle keyboard notifications
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // Remove keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    // MARK: - Refresh methods
    
    func updateComment(_ comment: String) {
        self.commentTextView.text = comment
        self.commentPlaceholderLabel.isHidden = comment.count > 0
    }
    
    func refresh() {
        self.commentTextView.text = ""
        self.emailTextField.text = ""
        self.emailPlaceholderLabel.isHidden = false
        self.commentPlaceholderLabel.isHidden = false
        self.emailTextField.becomeFirstResponder()
    }
    
    func displayError(type: AbuseErrorType) {
        let errorMessage: String
        switch type {
        case .missingEmail, .invalidEmail:
            errorMessage = "widget.error.email".loc()
        case .missingComment, .invalidComment:
            errorMessage = "widget.error.comment".loc()
        default:
            errorMessage = ""
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "widget.mobile.app.abuse.error.title".loc(), message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "widget.mobile.app.abuse.error.ok".loc(), style: .default, handler: nil))
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.windowLevel = UIWindow.Level.normal
            window.makeKeyAndVisible()
            window.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
        
    // MARK: - IBActions
    
    @IBAction func confirmAction(_ sender: Any) {
        self.delegate?.confirmAbuse(email: self.emailTextField.text!, comment: self.commentTextView.text)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.delegate?.cancelAbuse()
    }    
    // MARK - UITextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.commentTextView.becomeFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\t" {
            self.commentTextView.becomeFirstResponder()
            return false
        }
        self.emailPlaceholderLabel.isHidden = !(range.location == 0 && string.count == 0)
        return true
    }
        
    // MARK: - UITextViewDelegate methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.frame.height < 350 { // special case for small screens (iPhone 4)
            self.delegate?.willBeginEditingComment()
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        else {
            self.commentPlaceholderLabel.isHidden = !(range.location == 0 && text.count == 0)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        self.commentCounterLabel.text = "\(textLength)"
        
        if textLength > 400 {
            textView.deleteBackward()
        }
    }
        
    // MARK: - Keyboard functions
    
    @objc func keyboardWillChangeFrame(_ notification: Notification)
    {
        let keyboardHeight = notification.keyboardHeight(forView: self)
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        
        self.bottomViewBottomConstraint.constant = keyboardHeight - self.bottomView.frame.height
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        self.bottomViewBottomConstraint.constant = 10
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }


}


