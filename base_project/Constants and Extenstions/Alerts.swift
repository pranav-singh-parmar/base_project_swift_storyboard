//
//  Alerts.swift
//  base_project
//
//  Created by Pranav Singh on 26/08/22.
//

import Foundation
import UIKit

//MARK: - UIAlertController
extension UIAlertController {
    //MARK: - Initializers
    convenience init(ofStyle style: UIAlertController.Style,
                     withTitle title: String?,
                     andMessage message: String?) {
        self.init(title: "", message: "", preferredStyle: style)
        self.setTitle(title)
        self.setMessage(title)
    }
    
    private func setTitle(_ title: String?) {
        guard let title else {
            return
        }
        
        let attributedTitleKey = "attributedTitle"
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont.bitterMedium(size: 17),
                               NSAttributedString.Key.foregroundColor: UIColor.blackColor]
        let titleString = NSAttributedString(string: title,
                                             attributes: titleAttributes)
        self.setValue(titleString,
                      forKey: attributedTitleKey)
    }
    
    private func setMessage(_ message: String?) {
        guard let message else {
            return
        }
        
        let attributedMessageKey = "attributedMessage"
        let messageAttributes = [NSAttributedString.Key.font: UIFont.bitterRegular(size: 14),
                                 NSAttributedString.Key.foregroundColor: UIColor.blackColor]
        let messageString = NSAttributedString(string: message,
                                               attributes: messageAttributes)
        self.setValue(messageString,
                      forKey: attributedMessageKey)
    }
    
    //MARK: - Actions
    func addOKButton() {
        self.addAction(havingTitle: AppTexts.AlertMessages.ok.uppercased(),
                       ofStyle: .default)
    }
    
    func addAction(havingTitle title: String,
                   ofStyle style: UIAlertAction.Style,
                   withAction action: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title,
                                     style: style,
                                     handler: action))
    }
    
    func present(_ vc: UIViewController? = nil) {
        (vc ?? UIApplication.shared.getTopViewController())?.present(self, animated: true)
    }
}

//MARK: - Alert Class
class Alerts {
    func showToast(withMessage message: String, seconds: Double = 2.0) {
        let alert = UIAlertController(ofStyle: .alert,
                                      withTitle: message,
                                      andMessage: nil)
        //alert.view.backgroundColor = UIColor.lightPrimaryColor
        //alert.view.alpha = 0.6
        //alert.view.layer.cornerRadius = 15
        
        alert.present()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func errorAlertWith(message: String) {
        let alert = UIAlertController(ofStyle: .alert,
                                      withTitle: AppTexts.AlertMessages.errorWithExclamation,
                                      andMessage: message)
        alert.addOKButton()
        alert.present()
    }

    func okAlert(withTitle title: String,
                 message: String,
                 defaultButtonTitle: String = AppTexts.AlertMessages.ok) {
        let alert = UIAlertController(ofStyle: .alert,
                                      withTitle: title,
                                      andMessage: message)
        alert.addOKButton()
        alert.present()
    }

    func internetNotConnectedAlert(outputBlock: @escaping () -> Void) {
        let alert = UIAlertController(ofStyle: .alert,
                                      withTitle: AppTexts.AlertMessages.networkUnreachableWithExclamation,
                                      andMessage: AppTexts.AlertMessages.youAreNotConnectedToInternet)
        alert.addAction(havingTitle: AppTexts.AlertMessages.tapToRetry,
                        ofStyle: .default) { _ in
            outputBlock()
        }
        alert.present()
    }

    func handle401StatueCode() {
        let alert = UIAlertController(ofStyle: .alert,
                                      withTitle: AppTexts.AlertMessages.sessionExpiredWithExclamation,
                                      andMessage: AppTexts.AlertMessages.yourSessionHasExpiredPleaseLoginAgain)
        alert.addAction(havingTitle: AppTexts.AlertMessages.ok.uppercased(),
                        ofStyle: .default) { _ in
            Singleton.sharedInstance.generalFunctions.deinitilseAllVariables()
        }
        alert.present()
    }
}
