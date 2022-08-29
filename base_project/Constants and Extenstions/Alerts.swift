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
    
    func errorAlert(title: String = "Error!", message: String){
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        alert.setValue(titleString, forKey: attributedTitleKey)
        
        let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        alert.setValue(messageString, forKey: attributedMessageKey)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        let vc = Singleton.sharedInstance.generalFunctions.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func alertWithTwoButtonsAndActionOnSecond(title: String, message: String, firstButtonTitle: String, secondButtonTitle: String, secondButtonAction: @escaping ()-> Void){
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        alert.setValue(titleString, forKey: attributedTitleKey)
        
        let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        alert.setValue(messageString, forKey: attributedMessageKey)
        
        alert.addAction(UIAlertAction(title: firstButtonTitle, style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: secondButtonTitle, style: UIAlertAction.Style.default, handler: { _ in
            secondButtonAction()
        }))
        
        let vc = Singleton.sharedInstance.generalFunctions.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func internetNotConnectedAlert(outputBlock : @escaping () -> Void){
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleString = NSAttributedString(string: "Network Unreachable!", attributes: titleAttributes)
        alert.setValue(titleString, forKey: attributedTitleKey)
        
        let messageString = NSAttributedString(string: "You are not connected to Internet", attributes: messageAttributes)
        alert.setValue(messageString, forKey: attributedMessageKey)
        
        alert.addAction(UIAlertAction(title: "Tap to Retry", style: UIAlertAction.Style.default) { (UIAlertAction) in
            outputBlock()
        })
        
        let vc = Singleton.sharedInstance.generalFunctions.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func handle401StatueCode(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleString = NSAttributedString(string: "Session Expired", attributes: titleAttributes)
        alert.setValue(titleString, forKey: attributedTitleKey)
        
        let messageString = NSAttributedString(string: "Your Session has been Expired, PLease Login Again.", attributes: messageAttributes)
        alert.setValue(messageString, forKey: attributedMessageKey)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            Singleton.sharedInstance.generalFunctions.deinitilseAllVariables()
        }))
        
        
        let vc = Singleton.sharedInstance.generalFunctions.getTopViewController()
        vc?.present(alert, animated: true, completion: nil)
    }
}
