//
//  GeneralFunctions.swift
//  base_project
//
//  Created by Pranav Singh on 26/08/22.
//

import Foundation
import UIKit

class GeneralFunctions {
    
    func deinitilseAllVariables() {
        
        //remove all user default values
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
    }
    
}
