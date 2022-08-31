//
//  GeneralFunctions.swift
//  base_project
//
//  Created by Pranav Singh on 26/08/22.
//

import Foundation
import UIKit

class GeneralFunctions {
    
    func getTopViewController() -> UIViewController? {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        return nil
    }
    
    func getNavBarHeight() -> CGFloat {
        if let vc = getTopViewController() {
            return vc.navigationController?.navigationBar.bounds.height ?? 0
        }
        return 0
    }
    
    func structToData<T: Encodable>(_ model: T) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(model)
            return jsonData
        } catch { print(error.localizedDescription) }
        return nil
    }
    
    func structToJson<T: Encodable>(_ model: T) -> Any? {
        do {
            let jsonData = try JSONEncoder().encode(model)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return json
        } catch { print(error.localizedDescription) }
        return nil
    }
    
    func structToParameters<T: Encodable>(_ model: T) -> [String: Any]? {
        if let json = structToJson(model){
            if let parameter = json as? [String: Any] {
                return parameter
            }
        }
        return nil
    }
    
    func jsonToStruct<T: Decodable>(json: [String: Any], decodingStruct: T.Type) -> T? {
        do {
            let realData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let model = try Singleton.sharedInstance.jsonDecoder.decode(decodingStruct.self, from: realData)
            return model
        } catch {
            print("decoding error", error.localizedDescription)
        }
        return nil
    }
    
    func deinitilseAllVariables() {
        
        //remove all user default values
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
    }
    
}
