//
//  AppConstants.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import UIKit

//MARK: - AppURLs
struct AppURLs {
    static let baseURL = "https://www.breakingbadapi.com/"
    
    static func getAPIURL() -> String {
        return baseURL + "api/"
    }
}

//MARK: - UIColor
extension UIColor {
    static let blackColor = UIColor(named: "blackColor") ?? UIColor.clear
    static let blackColorForAllModes = UIColor(named: "blackColorForAllModes") ?? UIColor.clear
    static let whiteColor = UIColor(named: "whiteColor") ?? UIColor.clear
    static let whiteColorForAllModes = UIColor(named: "whiteColorForAllModes") ?? UIColor.clear
    
    static let defaultLightGray = UIColor(named: "defaultLightGray") ?? UIColor.clear
    static let shimmerColor = UIColor(named: "shimmerColor") ?? UIColor.clear
}

//MARK: - UIFont
extension UIFont {
    static func bitterLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Light", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Medium", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Bold", size: size) ?? .systemFont(ofSize: size)
    }
}
