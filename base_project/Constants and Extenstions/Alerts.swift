//
//  Alerts.swift
//  base_project
//
//  Created by Pranav Singh on 26/08/22.
//

import Foundation
import UIKit

class Alerts {
    //MARK: - variables
    private let attributedTitleKey = "attributedTitle"
    private let attributedMessageKey = "attributedMessage"
    
    private let titleAttributes = [NSAttributedString.Key.font: UIFont.bitterMedium(size: 17), NSAttributedString.Key.foregroundColor: UIColor.blackColor]
    private let messageAttributes = [NSAttributedString.Key.font: UIFont.bitterRegular(size: 14), NSAttributedString.Key.foregroundColor: UIColor.blackColor]
    
    func getAlertController(ofStyle style: UIAlertController.Style, withTitle title: String?, andMessage message: String?) -> UIAlertController {
        let alert = UIAlertController(title: "", message: "", preferredStyle: style)
        
        if let title {
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            alert.setValue(titleString, forKey: attributedTitleKey)
        }
        
        if let message {
            let messageString = NSAttributedString(string: message, attributes: messageAttributes)
            alert.setValue(messageString, forKey: attributedMessageKey)
        }
        
        return alert
    }
    
    func errorAlertWith(message: String){
        alertWith(title: AppTexts.AlertMessages.errorWithExclamation, message: message)
    }

    func alertWith(title: String, message: String, defaultButtonTitle: String = AppTexts.AlertMessages.ok) {
        let alert = getAlertController(ofStyle: .alert, withTitle: title, andMessage: message)

        alert.addAction(UIAlertAction(title: AppTexts.AlertMessages.ok.uppercased(), style: UIAlertAction.Style.default, handler: nil))

        let vc = UIApplication.shared.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }

    func internetNotConnectedAlert(outputBlock : @escaping () -> Void){
        let alert = getAlertController(ofStyle: .alert,
                                       withTitle: AppTexts.AlertMessages.networkUnreachableWithExclamation,
                                       andMessage: AppTexts.AlertMessages.youAreNotConnectedToInternet)

        alert.addAction(UIAlertAction(title: AppTexts.AlertMessages.tapToRetry, style: UIAlertAction.Style.default) { _ in
            outputBlock()
        })

        let vc = UIApplication.shared.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }

    func handle401StatueCode(){
        let alert = getAlertController(ofStyle: .alert,
                                       withTitle: AppTexts.AlertMessages.sessionExpiredWithExclamation,
                                       andMessage: AppTexts.AlertMessages.yourSessionHasExpiredPleaseLoginAgain)

        alert.addAction(UIAlertAction(title: AppTexts.AlertMessages.ok.uppercased(), style: UIAlertAction.Style.default, handler: { _ in
            Singleton.sharedInstance.generalFunctions.deinitilseAllVariables()
        }))


        let vc = UIApplication.shared.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }
}
